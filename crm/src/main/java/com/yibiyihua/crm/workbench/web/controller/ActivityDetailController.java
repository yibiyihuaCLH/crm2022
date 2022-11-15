package com.yibiyihua.crm.workbench.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.workbench.bean.Activity;
import com.yibiyihua.crm.workbench.bean.ActivityRemark;
import com.yibiyihua.crm.workbench.service.ActivityRemarkService;
import com.yibiyihua.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/11 9:45
 * @description：市场活动详情控制层
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/activity")
@Controller
public class ActivityDetailController {
    @Autowired
    ActivityService activityService;

    @Autowired
    ActivityRemarkService activityRemarkService;

    /**
     * 查询市场活动详情（跳转市场活动详情页面）
     * @param id
     * @param request
     * @return
     */
    @RequestMapping("/queryActivityDetail.do")
    public String queryActivityDetail(String id, HttpServletRequest request) {
        Activity activity = activityService.queryActivityForDetailById(id);
        List<ActivityRemark> activityRemarks = activityRemarkService.queryActivityRemarkForDetailByActivityId(id);
        //将市场活动和市场活动备注信息返回市场活动详情页面
        request.setAttribute("activity",activity);
        request.setAttribute("activityRemarks",activityRemarks);
        return "workbench/activity/detail";
    }

    /**
     * 保存创建的市场活动备注
     * @param activityRemark
     * @param session
     * @return
     */
    @RequestMapping("/saveCreateActivityRemark")
    @ResponseBody
    public Object saveCreateActivityRemark(ActivityRemark activityRemark, HttpSession session) {
        //封装参数
        activityRemark.setId(UUIDUtil.uuidToStr());
        activityRemark.setCreateTime(DateUtil.parseDateToStr(new Date()));
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        activityRemark.setCreateBy(sessionUser.getId());
        activityRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_NO);
        //生成响应信息
        ReturnObject returnObject = new ReturnObject();
        try {
            //添加市场活动备注
            int count = activityRemarkService.addActivityRemark(activityRemark);
            if (count > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(activityRemark);
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统繁忙，请重试....");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 根据id删除市场活动备注
     * @param id
     * @return
     */
    @RequestMapping("/deleteActivityRemark")
    @ResponseBody
    public Object deleteActivityRemark(String id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据id删除市场活动备注
            activityRemarkService.deleteActivityRemarkById(id);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 修改市场活动备注内容
     * @param activityRemark
     * @param session
     * @return
     */
    @RequestMapping("/editActivityRemarkNoteContent")
    @ResponseBody
    public Object editActivityRemarkNoteContent(ActivityRemark activityRemark,HttpSession session) {
        //封装参数
        activityRemark.setEditTime(DateUtil.parseDateToStr(new Date()));
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        activityRemark.setEditBy(sessionUser.getId());
        activityRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_YES);
        ReturnObject returnObject = new ReturnObject();
        try {
            int count = activityRemarkService.editActivityRemarkById(activityRemark);
            if (count > 0) {
                //封装返回参数
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(activityRemark);
                returnObject.setMessage("修改成功！");
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统繁忙，请重试....");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }
}
