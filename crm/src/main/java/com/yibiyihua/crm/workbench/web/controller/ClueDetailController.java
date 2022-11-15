package com.yibiyihua.crm.workbench.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.settings.bean.DictionaryValue;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.service.DictionaryValueService;
import com.yibiyihua.crm.workbench.bean.*;
import com.yibiyihua.crm.workbench.service.ActivityService;
import com.yibiyihua.crm.workbench.service.ClueActivityRelationService;
import com.yibiyihua.crm.workbench.service.ClueRemarkService;
import com.yibiyihua.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/14 11:09
 * @description：线索详情控制层
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/clue")
@Controller
public class ClueDetailController {
    @Autowired
    private ClueService clueService;
    @Autowired
    private ClueRemarkService clueRemarkService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private ClueActivityRelationService clueActivityRelationService;
    @Autowired
    private DictionaryValueService dictionaryValueService;

    /**
     * 查询线索详情（跳转线索详情页面）
     * @param clueId
     * @param request
     * @return
     */
    @RequestMapping("/queryClueDetail.do")
    public String queryClueDetail(String clueId, HttpServletRequest request) {
        //查询线索详细信息
        Clue clue = clueService.queryClueForDetailById(clueId);
        //查询线索关联备注
        List<ClueRemark> clueRemarks = clueRemarkService.queryClueRemarkFroDetailByClueId(clueId);
        //查询线索关联市场活动
        List<Activity> activities = activityService.queryActivityByClueId(clueId);
        //将查询结果封装至request中
        request.setAttribute("clue",clue);
        request.setAttribute("clueRemarks",clueRemarks);
        request.setAttribute("activities",activities);
        //携带数据跳转详情页面
        return "workbench/clue/detail";
    }

    /**
     * 保存创建的线索备注
     * @param clueRemark
     * @param session
     * @return
     */
    @RequestMapping("/saveCreateClueRemarkNoteContent")
    @ResponseBody
    public Object saveCreateClueRemarkNoteContent(ClueRemark clueRemark,HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //封装参数
        clueRemark.setId(UUIDUtil.uuidToStr());
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        clueRemark.setCreateBy(sessionUser.getId());
        clueRemark.setCreateTime(DateUtil.parseDateToStr(new Date()));
        clueRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_NO);
        try {
            //添加线索备注
            int result = clueRemarkService.saveCreateClueRemark(clueRemark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(clueRemark);
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
     * 删除线索
     * @param id
     * @return
     */
    @RequestMapping("/deleteClueRemark")
    @ResponseBody
    public Object deleteClueRemark(String id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据id删除线索备注
            clueRemarkService.deleteClueRemarkById(id);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 保存编辑的线索备注
     * @param clueRemark
     * @param session
     * @return
     */
    @RequestMapping("/saveEditClueRemarkNoteContent")
    @ResponseBody
    public Object saveEditClueRemarkNoteContent(ClueRemark clueRemark, HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //封装参数
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        clueRemark.setEditBy(sessionUser.getId());
        clueRemark.setEditTime(DateUtil.parseDateToStr(new Date()));
        clueRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_YES);
        try {
            //更新线索备注
            int result = clueRemarkService.saveEditClueRemarkById(clueRemark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(clueRemark);
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

    /**
     * 模糊查询未关联的市场活动
     * @param name
     * @param ids
     * @return
     */
    @RequestMapping("/queryActivityWithoutRelation")
    @ResponseBody
    public Object queryActivityWithoutRelation(String name,String[] ids) {
        Map<String,Object> map = new HashMap<>();
        map.put("name",name);
        map.put("ids",ids);
        List<Activity> activityList = activityService.queryActivityByNameWithoutRelation(map);
        return activityList;
     }

    /**
     * 添加创建的线索、市场活动关系
     * @param clueId
     * @param activityIds
     * @return
     */
    @RequestMapping("/addCreateClueActivityRelation")
    @ResponseBody
    public Object addCreateClueActivityRelation(String clueId,String[] activityIds) {
        ReturnObject returnObject = new ReturnObject();
        //对线索、市场活动关联记录封装
        List<ClueActivityRelation> clueActivityRelationList = new ArrayList<>();
        for (int i = 0; i < activityIds.length; i++) {
            ClueActivityRelation clueActivityRelation = new ClueActivityRelation();
            clueActivityRelation.setId(UUIDUtil.uuidToStr());
            clueActivityRelation.setClueId(clueId);
            clueActivityRelation.setActivityId(activityIds[i]);
            //判断线索、市场活动是否已被绑定
            int count = clueActivityRelationService.queryRelationshipCountByClueActivityId(clueActivityRelation);
            if (count > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统繁忙，请重试....");
                return returnObject;
            }
            //将每一条线索对应的市场活动放入关联集合中
            clueActivityRelationList.add(clueActivityRelation);
        }
        try {
            int count = clueActivityRelationService.addCreateClueActivityRelation(clueActivityRelationList);
            if (count > 0) {
                //查询市场活动记录
                List<Activity> activities = activityService.queryActivityByIds(activityIds);
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(activities);
                returnObject.setMessage("成功关联" + count + "条市场活动！");
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
     * 根据线索id、市场活动id解除关联
     * @param clueActivityRelation
     * @return
     */
    @RequestMapping("/cancelClueAndActivityRelationship")
    @ResponseBody
    public Object cancelClueAndActivityRelationship(ClueActivityRelation clueActivityRelation) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据id解除线索、市场活动关联关系
            clueActivityRelationService.deleteRelationshipByClueActivityId(clueActivityRelation);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setMessage("解除成功！");
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 跳转线索转换页面
     * @param id
     * @param request
     * @return
     */
    @RequestMapping("/clueConvert.do")
    public String clueConvert(String id,HttpServletRequest request) {
        //获取“线索”信息
        Clue clue = clueService.queryClueForDetailById(id);
        //获取“阶段”下拉列表值
        List<DictionaryValue> stages = dictionaryValueService.queryDictionaryValueByTypeCode("stage");
        request.setAttribute("clue",clue);
        request.setAttribute("stages",stages);
        //携带数据返回线索转换页面
        return "workbench/clue/convert";
    }

    /**
     * 查询线索所关联的市场活动
     * @param name
     * @param clueId
     * @return
     */
    @RequestMapping("/queryRelationActivity")
    @ResponseBody
    public Object queryRelationActivity(String name,String clueId) {
        Map<String, Object> map = new HashMap<>();
        map.put("name",name);
        map.put("clueId",clueId);
        //根据名称模糊查询线索所关联的市场活动
        List<Activity> activities = activityService.queryActivityByNameAndClueId(map);
        return activities;
    }

    /**
     * 线索转换
     * @param clueId
     * @param session
     * @return
     */
    @RequestMapping("/ClueConvert.do")
    @ResponseBody
    public Object ClueConvert(
            String clueId,
            boolean isCreateTran,
            Transaction transaction,
            HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        Map<String,Object> map = new HashMap<>();
        map.put("clueId",clueId);
        map.put("isCreateTran",isCreateTran);
        map.put("transaction",transaction);
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        map.put(Constants.SESSION_USER,sessionUser.getId());
        try {
            clueService.saveClueConvert(map);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setMessage("转换成功！");
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }
}

