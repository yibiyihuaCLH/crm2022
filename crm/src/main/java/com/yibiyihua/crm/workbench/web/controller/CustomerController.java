package com.yibiyihua.crm.workbench.web.controller;

import com.yibiyihua.crm.commons.bean.ReturnObject;
import com.yibiyihua.crm.commons.constants.Constants;
import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.settings.bean.User;
import com.yibiyihua.crm.settings.service.UserService;
import com.yibiyihua.crm.workbench.bean.Customer;
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
 * @date ：Created in 2022/10/18 12:41
 * @description：客户控制层
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/customer")
@Controller
public class CustomerController {
    @Autowired
    private UserService userService;
    @Autowired
    private CustomerService customerService;

    /**
     * 客户跳转页面
     * @param request
     * @return
     */
    @RequestMapping("/index.do")
    public String index(HttpServletRequest request) {
        List<User> users = userService.queryAllUsers();
        //客户页面加载将所有者信息存在request作用域中
        request.setAttribute("users",users);
        //携带数据跳转客户页面
        return "workbench/customer/index";
    }

    /**
     * 根据条件分页查询客户记录
     * @param customer
     * @param pageNo
     * @param pageSize
     * @return
     */
    @RequestMapping("/queryCustomerByConditionForPage")
    @ResponseBody
    public Object queryCustomerByConditionForPage(
            Customer customer,
            int pageNo,
            int pageSize) {
        //封装参数
        Map<String,Object> map = new HashMap<>();
        map.put("name",customer.getName());
        map.put("owner",customer.getOwner());
        map.put("phone",customer.getPhone());
        map.put("website",customer.getWebsite());
        int beginNo = pageSize * (pageNo - 1);
        map.put("beginNo",beginNo);
        map.put("pageSize",pageSize);
        //分页查询客户详细信息
        List<Customer> customerList = customerService.queryCustomerByConditionForPage(map);
        //查询客户记录总条数
        int totalRows = customerService.queryCustomerCountByCondition(customer);
        Map<String,Object> returnMap = new HashMap<>();
        returnMap.put("customerList",customerList);
        returnMap.put("totalRows",totalRows);
        return returnMap;
    }

    /**
     * 保存创建的客户信息
     * @param customer
     * @param session
     * @return
     */
    @RequestMapping("/saveCreateCustomer")
    @ResponseBody
    public Object saveCreateCustomer(Customer customer, HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //封装参数
        customer.setId(UUIDUtil.uuidToStr());
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        customer.setCreateBy(sessionUser.getId());
        customer.setCreateTime(DateUtil.parseDateToStr(new Date()));
        try {
            //保存创建的客户记录
            int result = customerService.saveCreateCustomer(customer);
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
     * 查询需要修改的客户信息
     * @param id
     * @return
     */
    @RequestMapping("/queryEditCustomer")
    @ResponseBody
    public Object queryEditCustomer(String id) {
        //根据id查询客户的信息
        Customer customer = customerService.queryCustomerById(id);
        return customer;
    }

    /**
     * 保存编辑的客户记录
     * @param customer
     * @param session
     * @return
     */
    @RequestMapping("/saveEditCustomer")
    @ResponseBody
    public Object saveEditCustomer(Customer customer,HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        //进一步封装客户信息
        User sessionUser = (User) session.getAttribute(Constants.SESSION_USER);
        customer.setEditBy(sessionUser.getId());
        customer.setEditTime(DateUtil.parseDateToStr(new Date()));
        try {
            //根据id保存编辑的客户记录
            int result = customerService.saveEditCustomerById(customer);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("修改成功！");
            }else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
                returnObject.setMessage("系统繁忙，请重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试...");
        }
        return returnObject;
    }

    /**
     * 批量删除客户记录
     * @param id
     * @return
     */
    @RequestMapping("/deleteCustomer")
    @ResponseBody
    public Object deleteCustomer(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        try {
            //根据ids删除客户记录
            int count = customerService.deleteCustomerByIds(id);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setMessage("成功删除" + count + "条记录！");
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FALSE);
            returnObject.setMessage("系统繁忙，请重试...");
        }
        return returnObject;
    }
}
