package com.yibiyihua.crm.workbench.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.settings.bean.DictionaryValue;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.service.DictionaryValueService;
import com.yibiyihua.crm.settings.service.UserService;
import com.yibiyihua.crm.workbench.bean.*;
import com.yibiyihua.crm.workbench.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/20 17:50
 * @description：联系人详情控制层
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/contacts")
@Controller
public class ContactsDetailController {
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private ContactsRemarkService contactsRemarkService;
    @Autowired
    private TransactionService transactionService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private ContactsActivityRelationService contactsActivityRelationService;
    @Autowired
    private UserService userService;
    @Autowired
    private DictionaryValueService dictionaryValueService;

    /**
     * 查询联系人详细信息
     * @param contactsId
     * @param request
     * @return
     */
    @RequestMapping("/queryContactsForDetail.do")
    public String queryContactsForDetail(String contactsId, HttpServletRequest request) {
        //根据联系人id查询联系人详细信息
        Contacts contacts = contactsService.queryContactsForDetailByContactsId(contactsId);
        //根据联系人id查询联系人备注
        List<ContactsRemark> contactsRemarkList = contactsRemarkService.queryContactsRemarkByContactsId(contactsId);
        //根据联系人id查询联系人交易
        List<Transaction> transactions = transactionService.queryTransactionByContactsId(contactsId);
        List<Map<String,Object>> transactionList = new ArrayList<>();
        for (Transaction transaction :transactions) {
            Map<String, Object> map = getReturnTran(transaction);
            transactionList.add(map);
        }
        //根据联系人id查询联系人关联的市场活动
        List<Activity> activityList = activityService.queryActivityByContactsId(contactsId);
        //查找所有者
        List<User> userList = userService.queryAllUsers();
        //查找阶段
        List<DictionaryValue> stageList = dictionaryValueService.queryDictionaryValueByTypeCode("stage");
        //查找类型
        List<DictionaryValue> typeList = dictionaryValueService.queryDictionaryValueByTypeCode("transactionType");
        //查找来源
        List<DictionaryValue> sourceList = dictionaryValueService.queryDictionaryValueByTypeCode("source");
        request.setAttribute("userList",userList);
        request.setAttribute("stageList",stageList);
        request.setAttribute("typeList",typeList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("contacts",contacts);
        request.setAttribute("contactsRemarkList",contactsRemarkList);
        request.setAttribute("transactionList",transactionList);
        request.setAttribute("activityList",activityList);
        return "workbench/contacts/detail";
    }

    /**
     * 保存联系人备注内容
     * @param contactsRemark
     * @param session
     * @return
     */
    @RequestMapping("/saveCreateContactsRemarkNoteContent")
    @ResponseBody
    public Object saveCreateContactsRemarkNoteContent(ContactsRemark contactsRemark, HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装联系人信息
        contactsRemark.setId(UUIDUtil.uuidToStr());
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        contactsRemark.setCreateBy(sessionUser.getId());
        contactsRemark.setCreateTime(DateUtil.parseDateToStr(new Date()));
        contactsRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_NO);
        try {
            //保存创建的联系人备注
            int result = contactsRemarkService.saveCreateContactsRemark(contactsRemark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(contactsRemark);
            } else {
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
     * 删除备注
     * @param id
     * @return
     */
    @RequestMapping("/deleteContactsRemark")
    @ResponseBody
    public Object deleteContactsRemark(String id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据id删除联系人备注
            contactsRemarkService.deleteContactsRemarkById(id);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 保存编辑的联系人备注内容
     * @param contactsRemark
     * @param session
     * @return
     */
    @RequestMapping("/saveEditContactsRemarkNoteContent")
    @ResponseBody
    public Object saveEditContactsRemarkNoteContent(ContactsRemark contactsRemark,HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装联系人备注信息
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        contactsRemark.setEditBy(sessionUser.getId());
        contactsRemark.setEditTime(DateUtil.parseDateToStr(new Date()));
        contactsRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_YES);
        try {
            //根据id保存编辑的联系人备注
            int result = contactsRemarkService.saveEditContactsRemarkNoteContentById(contactsRemark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(contactsRemark);
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
     * 删除客户交易
     * @param tranId
     * @return
     */
    @RequestMapping("/deleteTransaction")
    @ResponseBody
    public Object deleteTransaction(String tranId) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据交易id删除交易
            transactionService.deleteTransactionById(tranId);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setMessage("删除成功！");
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
     * @param contactsId
     * @param activityIds
     * @return
     */
    @RequestMapping("/addCreateContactsActivityRelation")
    @ResponseBody
    public Object addCreateContactsActivityRelation(String contactsId,String[] activityIds) {
        ReturnObject returnObject = new ReturnObject();
        //对联系人、市场活动关联记录封装
        List<ContactsActivityRelation> contactsActivityRelationList = new ArrayList<>();
        for (int i = 0; i < activityIds.length; i++) {
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.uuidToStr());
            contactsActivityRelation.setContactsId(contactsId);
            contactsActivityRelation.setActivityId(activityIds[i]);
            //判断联系人、市场活动是否已被绑定
            int count = contactsActivityRelationService.queryRelationshipCountByContactsActivityId(contactsActivityRelation);
            if (count > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统繁忙，请重试....");
                return returnObject;
            }
            //将每一条联系人对应的市场活动放入关联集合中
            contactsActivityRelationList.add(contactsActivityRelation);
        }
        try {
            int count = contactsActivityRelationService.addCreateContactsActivityRelation(contactsActivityRelationList);
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
     * @param contactsActivityRelation
     * @return
     */
    @RequestMapping("/cancelContactsAndActivityRelationship")
    @ResponseBody
    public Object cancelContactsAndActivityRelationship(ContactsActivityRelation contactsActivityRelation) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据id解除线索、市场活动关联关系
            contactsActivityRelationService.deleteRelationshipByContactsActivityId(contactsActivityRelation);
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
     * 保存创建的交易
     * @param transaction
     * @param session
     * @return
     */
    @RequestMapping("/saveCreateTransaction")
    @ResponseBody
    public Object saveCreateContacts(Transaction transaction, HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装交易信息
        transaction.setId(UUIDUtil.uuidToStr());
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        String sessionUserId = sessionUser.getId();
        transaction.setCreateBy(sessionUserId);
        transaction.setCreateTime(DateUtil.parseDateToStr(new Date()));
        String tranName = transaction.getCustomerId() +"-"+ transaction.getName();
        transaction.setName(tranName);
        try {
            //保存创建的交易
            int result = transactionService.saveCreateTransaction(transaction,sessionUserId);
            if (result > 0) {
                Map<String, Object> map = getReturnTran(transaction);
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("创建成功！");
                returnObject.setObj(map);
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
     * 获取返回交易
     * @param transaction
     * @return
     */
    private Map<String, Object> getReturnTran(Transaction transaction) {
        Transaction returnTran = transactionService.queryTransactionForDetailById(transaction.getId());
        //获取可能性
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(returnTran.getStage()) + "%";
        Map<String, Object> map = new HashMap<>();
        map.put("id", returnTran.getId());
        map.put("name", returnTran.getName());
        map.put("money", returnTran.getMoney());
        map.put("stage", returnTran.getStage());
        map.put("expectedDate", returnTran.getExpectedDate());
        map.put("type", returnTran.getType());
        map.put("possibility", possibility);
        return map;
    }
}
