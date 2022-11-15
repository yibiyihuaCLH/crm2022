package com.yibiyihua.crm.settings.web.interceptor;

import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.settings.bean.User;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/25 16:10
 * @description：登录拦截器
 * @modified By：
 * @version: 1.0
 */
public class LoginInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object o) throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        if (user == null) {
            //账户未登录成功，跳转登录页面
            response.sendRedirect(request.getContextPath());
            return false;
        }
        //账户已登录，放行
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object o, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object o, Exception e) throws Exception {

    }
}
