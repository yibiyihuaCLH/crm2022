package com.yibiyihua.crm.workbench.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.settings.bean.DictionaryValue;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.service.DictionaryValueService;
import com.yibiyihua.crm.settings.service.UserService;
import com.yibiyihua.crm.workbench.bean.Activity;
import com.yibiyihua.crm.workbench.bean.Contacts;
import com.yibiyihua.crm.workbench.bean.Transaction;
import com.yibiyihua.crm.workbench.service.ActivityService;
import com.yibiyihua.crm.workbench.service.ContactsService;
import com.yibiyihua.crm.workbench.service.CustomerService;
import com.yibiyihua.crm.workbench.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/21 12:29
 * @description：交易控制层
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/transaction")
@Controller
public class TransactionController {
    @Autowired
    private UserService userService;
    @Autowired
    private DictionaryValueService dictionaryValueService;
    @Autowired
    private TransactionService transactionService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private CustomerService customerService;

    /**
     * 跳转交易页面
     * @param request
     * @return
     */
    @RequestMapping("/index.do")
    public String index(HttpServletRequest request) {
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
        //携带数据跳转交易页面
        return "workbench/transaction/index";
    }

    /**
     * 按条件分页查询交易记录和总记录条数
     * @param transaction
     * @param pageNo
     * @param pageSize
     * @return
     */
    @RequestMapping("/queryTransactionByConditionForPageAndQueryCountByCondition")
    @ResponseBody
    public Object queryTransactionByConditionForPageAndQueryCountByCondition(
            Transaction transaction,
            int pageNo,
            int pageSize
            ) {
        //封装查询条件
        Map<String,Object> map = new HashMap<>();
        map.put("owner", transaction.getOwner());
        map.put("name", transaction.getName());
        map.put("customerId", transaction.getCustomerId());
        map.put("stage", transaction.getStage());
        map.put("type", transaction.getType());
        map.put("source", transaction.getSource());
        map.put("contactsId", transaction.getContactsId());
        int beginNo = pageSize * (pageNo - 1);
        map.put("beginNo",beginNo);
        map.put("pageSize",pageSize);
        //根据查询条件分页查询交易记录
        List<Transaction> tranList = transactionService.queryTransactionByConditionForPage(map);
        //根据查询条件查询中交易条数
        int totalRows = transactionService.queryCountByCondition(map);
        Map<String,Object> returnMap = new HashMap<>();
        returnMap.put("tranList",tranList);
        returnMap.put("totalRows",totalRows);
        return returnMap;
    }

    /**
     * 获取阶段对应的可能性
     * @param stage
     * @return
     */
    @RequestMapping("/getPossibility")
    @ResponseBody
    public Object getPossibility(String stage) {
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String possibility = bundle.getString(stage) + "%";
        return possibility;
    }

    /**
     * 模糊查询客户名称
     * @param customerName
     * @return
     */
    @RequestMapping("/queryCustomerName")
    @ResponseBody
    public Object queryCustomerName(String customerName) {
        if (customerName == null || customerName == "") {
            return null;
        }
        //模糊查询客户名称
        String[] customerNameList = customerService.queryCustomerNameByLike(customerName);
        return customerNameList;
    }

    /**
     * 查询市场活动
     * @param name
     * @return
     */
    @RequestMapping("/queryActivity")
    @ResponseBody
    public Object queryActivity(String name) {
        //根据名称模糊查询市场活动
        List<Activity> activityList = activityService.queryActivityByNameLike(name);
        return activityList;
    }

    /**
     * 查询联系人
     * @param fullName
     * @return
     */
    @RequestMapping("queryContacts")
    @ResponseBody
    public Object queryContacts(String fullName,String customerName) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("fullName",fullName);
        map.put("customerName",customerName);
        //根据名称模糊查询联系人
        List<Contacts> contactsList = contactsService.queryContactsByNameLike(map);
        return contactsList;
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
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("创建成功！");
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
     * 查询交易
     * @param id
     * @return
     */
    @RequestMapping("/queryTransaction")
    @ResponseBody
    public Object queryTransaction(String id) {
        //根据id查询交易信息
        Transaction transaction = transactionService.queryTransactionById(id);
        //重新设置返回交易信息的名称
        String tranFullName = transaction.getName();
        transaction.setName(tranFullName.substring(tranFullName.indexOf("-")+1));
        //获取可能性
        ResourceBundle bundle = ResourceBundle.getBundle("possibility");
        String stageValue = dictionaryValueService.queryDictionaryValueById(transaction.getStage());
        String possibility = bundle.getString(stageValue) + "%";
        Map<String,Object> map = new HashMap<>();
        map.put("owner",transaction.getOwner());
        map.put("money",transaction.getMoney());
        map.put("name",transaction.getName());
        map.put("expectedDate",transaction.getExpectedDate());
        map.put("customer",transaction.getCustomerId());
        map.put("stage",transaction.getStage());
        map.put("type",transaction.getType());
        map.put("source",transaction.getSource());
        map.put("activity",transaction.getActivityId());
        map.put("contacts",transaction.getContactsId());
        map.put("description",transaction.getDescription());
        map.put("contactSummary",transaction.getContactSummary());
        map.put("nextContactTime",transaction.getNextContactTime());
        map.put("possibility",possibility);
        return map;
    }

    /**
     * 保存编辑的交易记录
     * @param transaction
     * @param createHistory
     * @return
     */
    @RequestMapping("/saveEditTransaction")
    @ResponseBody
    public Object saveEditTransaction (Transaction transaction,Boolean createHistory,HttpSession session){
        ReturnObject returnObject = new ReturnObject();
        //进一步封装交易信息
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        String sessionUserId = sessionUser.getId();
        transaction.setEditBy(sessionUserId);
        transaction.setEditTime(DateUtil.parseDateToStr(new Date()));
        String tranName = transaction.getCustomerId() +"-"+ transaction.getName();
        transaction.setName(tranName);
        try {
            //根据id保存编辑的交易记录
            int result = transactionService.saveEditTransactionById(transaction,createHistory,sessionUserId);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
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
     * 删除交易记录
     * @param id
     * @return
     */
    @RequestMapping("/deleteTransaction")
    @ResponseBody
    public Object deleteTransaction(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            int count = transactionService.deleteTransactionByIds(id);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setMessage("成功删除"+ count +"条交易记录");
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 根据阶段分组查询交易数
     * @return
     */
    @RequestMapping("/queryCountOfTranGroupByStage")
    @ResponseBody
    public Object queryCountOfTranGroupByStage() {
        return transactionService.queryCountOfTranGroupByStage();
    }

}
