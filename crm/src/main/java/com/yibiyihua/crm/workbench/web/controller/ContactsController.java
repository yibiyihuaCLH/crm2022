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
import com.yibiyihua.crm.workbench.service.ContactsService;
import com.yibiyihua.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/20 7:46
 * @description：联系人控制层
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/contacts")
@Controller
public class ContactsController {
    @Autowired
    private UserService userService;
    @Autowired
    private DictionaryValueService dictionaryValueService;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private CustomerService customerService;

    /**
     * 跳转联系人主页面
     * @param request
     * @return
     */
    @RequestMapping("/index.do")
    public String index(HttpServletRequest request) {
        //查询下拉列表
        List<User> users = userService.queryAllUsers();
        List<DictionaryValue> sources = dictionaryValueService.queryDictionaryValueByTypeCode("source");
        List<DictionaryValue> appellations = dictionaryValueService.queryDictionaryValueByTypeCode("appellation");
        request.setAttribute("users",users);
        request.setAttribute("sources",sources);
        request.setAttribute("appellations",appellations);
        //携带数据跳转至联系人默认页面
        return "workbench/contacts/index";
    }

    /**
     * 按条件分页查询联系人和总记录条数
     * @param contacts
     * @param pageNo
     * @param pageSize
     * @return
     */
    @RequestMapping("/queryContactsByConditionForPageAndQueryCountByCondition")
    @ResponseBody
    public Object queryContactsByConditionForPageAndQueryCountByCondition(
            Contacts contacts,
            int pageNo,
            int pageSize
            ) {
        //封装查询条件参数
        Map<String,Object> map = new HashMap<>();
        map.put("fullName",contacts.getFullName());
        map.put("customerId",contacts.getCustomerId());
        map.put("owner",contacts.getOwner());
        map.put("source",contacts.getSource());
        int beginNo = pageSize * (pageNo -1);
        map.put("beginNo",beginNo);
        map.put("pageSize",pageSize);
        //根据条件分页查询联系人
        List<Contacts> contactsList = contactsService.queryContactsByConditionForPage(map);
        //根据条件查询总记录条数
        int totalRows = contactsService.queryCountByCondition(map);
        Map<String,Object> returnMap = new HashMap<>();
        returnMap.put("contactsList",contactsList);
        returnMap.put("totalRows",totalRows);
        return returnMap;
    }

    /**
     * 删除联系人
     * @param id
     * @return
     */
    @RequestMapping("/deleteContacts")
    @ResponseBody
    public Object deleteContacts(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据ids删除联系人记录
            int count = contactsService.deleteContactsByIds(id);
            if (count == id.length) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("成功删除"+ count +"条记录！");
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统繁忙，请重试.....");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试.....");
        }
        return returnObject;
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
     * 查询联系人信息
     * @param id
     * @return
     */
    @RequestMapping("/queryContacts")
    @ResponseBody
    public Object contactsList(String id) {
        //根据id查询联系人信息
        Contacts contacts = contactsService.queryContactsById(id);
        return contacts;
    }

    /**
     * 保存更改的联系人信息
     * @param contacts
     * @param session
     * @return
     */
    @RequestMapping("/saveEditContacts")
    @ResponseBody
    public Object saveEditContacts(Contacts contacts,HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装联系人信息
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        String sessionUserId = sessionUser.getId();
        contacts.setEditBy(sessionUserId);
        contacts.setEditTime(DateUtil.parseDateToStr(new Date()));
        try {
            //保存创建的联系人
            int result = contactsService.saveEditContacts(contacts,sessionUserId);
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


}
