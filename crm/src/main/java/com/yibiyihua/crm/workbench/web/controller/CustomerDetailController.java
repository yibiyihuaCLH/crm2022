package com.yibiyihua.crm.workbench.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.settings.bean.DictionaryValue;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.service.DictionaryValueService;
import com.yibiyihua.crm.settings.service.UserService;
import com.yibiyihua.crm.workbench.bean.Contacts;
import com.yibiyihua.crm.workbench.bean.Customer;
import com.yibiyihua.crm.workbench.bean.CustomerRemark;
import com.yibiyihua.crm.workbench.bean.Transaction;
import com.yibiyihua.crm.workbench.service.ContactsService;
import com.yibiyihua.crm.workbench.service.CustomerRemarkService;
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
 * @date ：Created in 2022/10/19 9:26
 * @description：客户详情控制层
 * @modified By：
 * @version: 1.0
 */

@RequestMapping("/workbench/customer")
@Controller
public class CustomerDetailController {
    @Autowired
    private CustomerService customerService;
    @Autowired
    private CustomerRemarkService customerRemarkService;
    @Autowired
    private TransactionService transactionService;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private UserService userService;
    @Autowired
    private DictionaryValueService dictionaryValueService;

    /**
     * 查询客户详细信息（跳转详情页面）
     * @param id
     * @param request
     * @return
     */
    @RequestMapping("/queryCustomerForDetail.do")
    public String queryCustomerForDetail(String id, HttpServletRequest request) {
        //根据id查询客户详细信息
        Customer customer = customerService.queryCustomerForDetailById(id);
        //根据客户id查询客户备注
        List<CustomerRemark> customerRemarks = customerRemarkService.queryCustomerRemarkByCustomerId(id);
        //根据客户id查询客户交易
        List<Transaction> transactions = transactionService.queryTransactionByCustomerId(id);
        List<Map<String,Object>> transactionList = new ArrayList<>();
        for (Transaction transaction :transactions) {
            Map<String, Object> map = getReturnTran(transaction);
            transactionList.add(map);
        }
        //根据客户id查询联系人
        List<Contacts> contactsList = contactsService.queryContactsByCustomerId(id);
        //查询所有用户
        List<User> userList = userService.queryAllUsers();
        //查询来源
        List<DictionaryValue> sourceList = dictionaryValueService.queryDictionaryValueByTypeCode("source");
        //查询称呼
        List<DictionaryValue> appellationList = dictionaryValueService.queryDictionaryValueByTypeCode("appellation");
        //查询阶段
        List<DictionaryValue> stageList = dictionaryValueService.queryDictionaryValueByTypeCode("stage");
        //查询类型
        List<DictionaryValue> typeList = dictionaryValueService.queryDictionaryValueByTypeCode("transactionType");
        request.setAttribute("customer",customer);
        request.setAttribute("customerRemarks",customerRemarks);
        request.setAttribute("transactions",transactionList);
        request.setAttribute("contactsList",contactsList);
        request.setAttribute("userList",userList);
        request.setAttribute("sourceList",sourceList);
        request.setAttribute("appellationList",appellationList);
        request.setAttribute("stageList",stageList);
        request.setAttribute("typeList",typeList);

        //携带数据跳转客户详情页
        return "workbench/customer/detail";
    }

    /**
     * 保存创建的客户备注
     * @param customerRemark
     * @param session
     * @return
     */
    @RequestMapping("saveCreateCustomerRemark")
    @ResponseBody
    public Object saveCreateCustomerRemark(CustomerRemark customerRemark, HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装客户备注信息
        customerRemark.setId(UUIDUtil.uuidToStr());
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        customerRemark.setCreateBy(sessionUser.getId());
        customerRemark.setCreateTime(DateUtil.parseDateToStr(new Date()));
        customerRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_NO);
        try {
            //保存创建的客户备注
            int result = customerRemarkService.saveCreateCustomerRemark(customerRemark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(customerRemark);
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
     * 删除客户备注
     * @param id
     * @return
     */
    @RequestMapping("/deleteCustomerRemark")
    @ResponseBody
    public Object deleteCustomerRemark(String id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据客户备注id删除客户备注
            customerRemarkService.deleteCustomerRemarkById(id);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试....");
        }
        return returnObject;
    }

    /**
     * 保存编辑的客户备注内容
     * @param customerRemark
     * @param session
     * @return
     */
    @RequestMapping("/editCustomerRemarkNoteContent")
    @ResponseBody
    public Object editCustomerRemarkNoteContent(CustomerRemark customerRemark,HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装客户备注信息
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        customerRemark.setEditBy(sessionUser.getId());
        customerRemark.setEditTime(DateUtil.parseDateToStr(new Date()));
        customerRemark.setEditFlag(Constants.RETURN_OBJECT_EDIT_FLAG_YES);
        try {
            //保存编辑的客户备注
            int result = customerRemarkService.saveEditCustomerRemark(customerRemark);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("修改成功！");
                returnObject.setObj(customerRemark);
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
     * 删除客户联系人
     * @param contactsId
     * @return
     */
    @RequestMapping("/deleteContacts")
    @ResponseBody
    public Object deleteContacts(String contactsId) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据联系人id删除联系人
            contactsService.deleteContactsById(contactsId);
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
     * 保存创建的联系人
     * @param contacts
     * @param session
     * @return
     */
    @RequestMapping("/saveCreateContacts")
    @ResponseBody
    public Object saveCreateContacts(Contacts contacts, HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装联系人信息
        contacts.setId(UUIDUtil.uuidToStr());
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        String sessionUserId = sessionUser.getId();
        contacts.setCreateBy(sessionUserId);
        contacts.setCreateTime(DateUtil.parseDateToStr(new Date()));
        try {
            //保存创建的联系人
            int result = contactsService.saveCreateContacts(contacts,sessionUserId);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setObj(contacts);
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
