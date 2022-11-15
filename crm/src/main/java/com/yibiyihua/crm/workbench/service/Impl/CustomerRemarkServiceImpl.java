package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.CustomerRemark;
import com.yibiyihua.crm.workbench.mapper.CustomerRemarkMapper;
import com.yibiyihua.crm.workbench.service.CustomerRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/19 9:31
 * @description：客户备注业务逻辑层实体类
 * @modified By：
 * @version: 1.0
 */
@Service
public class CustomerRemarkServiceImpl implements CustomerRemarkService {
    @Autowired
    private CustomerRemarkMapper customerRemarkMapper;

    /**
     * 根据客户id查询客户备注
     * @param customerId
     * @return
     */
    @Override
    public List<CustomerRemark> queryCustomerRemarkByCustomerId(String customerId) {
        return customerRemarkMapper.selectCustomerRemarkByCustomerId(customerId);
    }

    /**
     * 保存创建的客户备注
     * @param customerRemark
     * @return
     */
    @Override
    public int saveCreateCustomerRemark(CustomerRemark customerRemark) {
        return customerRemarkMapper.insertCustomerRemark(customerRemark);
    }

    /**
     * 根据客户备注id删除客户备注
     * @param id
     * @return
     */
    @Override
    public int deleteCustomerRemarkById(String id) {
        return customerRemarkMapper.deleteCustomerRemarkById(id);
    }

    /**
     * 保存编辑的客户备注
     * @param customerRemark
     * @return
     */
    @Override
    public int saveEditCustomerRemark(CustomerRemark customerRemark) {
        return customerRemarkMapper.updateCustomerRemarkById(customerRemark);
    }
}
