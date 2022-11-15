package com.yibiyihua.crm.settings.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.text.ParseException;
import java.util.Date;
import java.util.HashMap;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/23 15:03
 * @description：User控制器
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/settings/qx/user")
@Controller
public class UserController {

    @Autowired
    private UserService userService;

    /**
     *跳转登录页面
     * @return
     */
    @RequestMapping("/toLogin.do")
    public String toLogin() {
        return "settings/qx/user/login";
    }

    /**
     * 登录验证
     * @param loginAct
     * @param loginPwd
     * @param isRemPwd
     * @param request
     * @param response
     * @param session
     * @return
     * @throws ParseException
     */
    @RequestMapping("/login")
    @ResponseBody
    public Object login(
            String loginAct, String loginPwd, String isRemPwd, HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ParseException, InterruptedException {
        //Thread.sleep(1000);
        HashMap<String, Object> map = new HashMap<>();
        map.put("loginAct", loginAct);
        map.put("loginPwd", loginPwd);
        //获取输入账号密码的用户信息
        User user = userService.queryUserByLoginActAndPwd(map);
        //生成响应信息
        ReturnObject returnObject = new ReturnObject();
        returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
        if (user == null) {
            //没有查询到用户记录
            returnObject.setMessage("账号或密码输入错误");
        } else {
            //查询到用户记录，再核对用户账号使用期限、ip限制、锁定状态
            if (new Date().getTime() > DateUtil.DateStrToLong(user.getExpireTime())) {
                returnObject.setMessage("用户已过期");
            } else if (!user.getAllowIps().contains(request.getRemoteAddr())) {
                returnObject.setMessage("ip受限");
            } else if ("0".equals(user.getLockState())) {
                returnObject.setMessage("用户状态被锁定");
            } else {
                //核对无误，登录成功
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                //十天内免登录
                Cookie c1;
                Cookie c2;
                if ("true".equals(isRemPwd)) {
                    //浏览器中存有账号、密码的cookie，不创建cookie(防止覆盖cookie有效时间)
                    c1 = null;
                    c2 = null;
                    for (Cookie cookie : request.getCookies()) {
                        if (Constants.COOKIE_LOGIN_ACCOUNT.equals(cookie.getName())) {
                            c1 = cookie;
                        } else if (Constants.COOKIE_LOGIN_PASSWORD.equals(cookie.getName())) {
                            c2 = cookie;
                        }
                    }
                    //浏览器中未存有账号、密码的cookie，创建有效期为十天的cookie
                    if (c1 == null || c2 == null) {
                        //创建cookie
                        c1 = new Cookie(Constants.COOKIE_LOGIN_ACCOUNT, user.getLoginAct());
                        c2 = new Cookie(Constants.COOKIE_LOGIN_PASSWORD, user.getLoginPwd());
                        //设置时间（十天）
                        c1.setMaxAge(10*24*60*60);
                        c2.setMaxAge(10*24*60*60);
                        //将cookie返回浏览器
                        response.addCookie(c1);
                        response.addCookie(c2);
                    }
                }else {
                    //同名cookie覆盖，值为空
                    c1 = new Cookie(Constants.COOKIE_LOGIN_ACCOUNT, "");
                    c2 = new Cookie(Constants.COOKIE_LOGIN_PASSWORD, "");
                    //清空时间
                    c1.setMaxAge(0);
                    c2.setMaxAge(0);
                    //将cookie返回浏览器
                    response.addCookie(c1);
                    response.addCookie(c2);
                }
                //将用户信息保存当前会话
                session.setAttribute(Constants.SESSION_USER, user);
            }
        }
         return returnObject;
    }

    /**
     * 安全退出
     * @param response
     * @param session
     * @return
     */
    @RequestMapping("/loginOut.do")
    public String loginOut(HttpServletResponse response,HttpSession session) {
        //将存有账号密码的cookie清空
        //同名cookie覆盖
        Cookie c1 = new Cookie(Constants.COOKIE_LOGIN_ACCOUNT, "");
        Cookie c2 = new Cookie(Constants.COOKIE_LOGIN_PASSWORD, "");
        //清空时间
        c1.setMaxAge(0);
        c2.setMaxAge(0);
        //将cookie返回浏览器
        response.addCookie(c1);
        response.addCookie(c2);
        //销毁session
        session.invalidate();
        return "redirect:/";
    }
}