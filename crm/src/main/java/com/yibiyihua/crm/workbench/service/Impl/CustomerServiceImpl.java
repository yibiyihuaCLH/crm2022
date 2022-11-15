package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.Customer;
import com.yibiyihua.crm.workbench.mapper.ContactsMapper;
import com.yibiyihua.crm.workbench.mapper.CustomerMapper;
import com.yibiyihua.crm.workbench.mapper.CustomerRemarkMapper;
import com.yibiyihua.crm.workbench.mapper.TransactionMapper;
import com.yibiyihua.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/18 13:08
 * @description：客户业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class CustomerServiceImpl implements CustomerService {
    @Autowired
    private CustomerMapper customerMapper;
    @Autowired
    private CustomerRemarkMapper customerRemarkMapper;
    @Autowired
    private TransactionMapper transactionMapper;
    @Autowired
    private ContactsMapper contactsMapper;

    /**
     * 根据查询条件分页查询客户记录
     * @param map
     * @return
     */
    @Override
    public List<Customer> queryCustomerByConditionForPage(Map<String, Object> map) {
        return customerMapper.selectCustomerByConditionForPage(map);
    }

    /**
     * 根据条件查询客户记录总条数
     * @param customer
     * @return
     */
    @Override
    public int queryCustomerCountByCondition(Customer customer) {
        return customerMapper.selectCustomerCountByCondition(customer);
    }

    /**
     * 保存创建的客户记录
     * @param customer
     * @return
     */
    @Override
    public int saveCreateCustomer(Customer customer) {
        return customerMapper.insertCustomer(customer);
    }

    /**
     * 根据id查询线索详细信息
     * @param id
     * @return
     */
    @Override
    public Customer queryCustomerForDetailById(String id) {
        return customerMapper.selectCustomerForDetailById(id);
    }

    /**
     * 根据id保存编辑的客户记录
     * @param customer
     * @return
     */
    @Override
    public int saveEditCustomerById(Customer customer) {
        return customerMapper.updateCustomerById(customer);
    }

    /**
     * 根据ids批量删除客户记录
     * @param ids
     * @return
     */
    @Override
    public int deleteCustomerByIds(String[] ids) throws Exception {
        //根据ids批量删除客户记录
        int count = customerMapper.deleteCustomerByIds(ids);
        if (count != ids.length) {
            throw new Exception();
        }
        //根据客户ids删除客户备注
        customerRemarkMapper.deleteCustomerRemarkByCustomerIds(ids);
        //根据客户ids删除客户交易
        transactionMapper.deleteTransactionByCustomerIds(ids);
        //根据客户ids删除客户联系人
        contactsMapper.deleteContactsByCustomerIds(ids);
        return count;
    }

    /**
     * 根据id查询客户记录
     * @param id
     * @return
     */
    @Override
    public Customer queryCustomerById(String id) {
        return customerMapper.selectCustomerById(id);
    }

    /**
     * 模糊查询客户名称
     * @param name
     * @return
     */
    @Override
    public String[] queryCustomerNameByLike(String name) {
        return customerMapper.selectCustomerNameByLike(name);
    }
}
