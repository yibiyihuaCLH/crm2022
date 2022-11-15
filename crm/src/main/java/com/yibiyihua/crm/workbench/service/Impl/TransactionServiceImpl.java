package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.commons.utils.DateUtil;
import com.yibiyihua.crm.commons.utils.UUIDUtil;
import com.yibiyihua.crm.workbench.bean.Customer;
import com.yibiyihua.crm.workbench.bean.Funnel;
import com.yibiyihua.crm.workbench.bean.Transaction;
import com.yibiyihua.crm.workbench.bean.TransactionHistory;
import com.yibiyihua.crm.workbench.mapper.CustomerMapper;
import com.yibiyihua.crm.workbench.mapper.TransactionHistoryMapper;
import com.yibiyihua.crm.workbench.mapper.TransactionMapper;
import com.yibiyihua.crm.workbench.mapper.TransactionRemarkMapper;
import com.yibiyihua.crm.workbench.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/19 14:39
 * @description：交易业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class TransactionServiceImpl implements TransactionService {
    @Autowired
    private TransactionMapper transactionMapper;
    @Autowired
    private CustomerMapper customerMapper;
    @Autowired
    private TransactionRemarkMapper transactionRemarkMapper;
    @Autowired
    private TransactionHistoryMapper transactionHistoryMapper;

    /**
     * 根据客户id查询关联交易
     * @param customerId
     * @return
     */
    @Override
    public List<Transaction> queryTransactionByCustomerId(String customerId) {
        return transactionMapper.selectTransactionByCustomerId(customerId);
    }

    /**
     * 根据id删除交易
     * @param id
     * @return
     */
    @Override
    public int deleteTransactionById(String id) {
        return transactionMapper.deleteTransactionById(id);
    }

    /**
     * 根据联系人id查询交易
     * @param contactsId
     * @return
     */
    @Override
    public List<Transaction> queryTransactionByContactsId(String contactsId) {
        return transactionMapper.selectTransactionByContactsId(contactsId);
    }

    /**
     * 根据查询条件分页查询交易记录
     * @param map
     * @return
     */
    @Override
    public List<Transaction> queryTransactionByConditionForPage(Map<String, Object> map) {
        return transactionMapper.selectTransactionByConditionForPage(map);
    }

    /**
     * 根据查询条件查询中交易条数
     * @param map
     * @return
     */
    @Override
    public int queryCountByCondition(Map<String, Object> map) {
        return transactionMapper.selectCountByCondition(map);
    }

    /**
     * 保存创建的交易
     * @param transaction
     * @param sessionUserId
     * @return
     */
    @Override
    public int saveCreateTransaction(Transaction transaction, String sessionUserId) {
        //添加交易历史
        createHistoryAndSetCustomerId(transaction, true, sessionUserId);
        //添加联系人记录
        return transactionMapper.insertTransaction(transaction);
    }

    /**
     * 根据id查询交易信息
     * @param id
     * @return
     */
    @Override
    public Transaction queryTransactionById(String id) {
        return transactionMapper.selectTransactionById(id);
    }

    /**
     * 根据id保存编辑的交易记录
     * @param transaction
     * @param sessionUserId
     * @return
     */
    @Override
    public int saveEditTransactionById(Transaction transaction,Boolean createHistory, String sessionUserId) {
        createHistoryAndSetCustomerId(transaction, createHistory, sessionUserId);
        return transactionMapper.updateTransactionById(transaction);
    }

    /**
     * 根据ids删除交易记录
     * @param ids
     * @return
     */
    @Override
    public int deleteTransactionByIds(String[] ids) throws Exception {
        int count = transactionMapper.deleteTransactionByIds(ids);
        if (count != ids.length) {
            throw new Exception();
        }
        //根据交易ids删除交易备注
        transactionRemarkMapper.deleteRemarkByTransactionIds(ids);
        //根据交易ids删除交易历史
        transactionHistoryMapper.deleteHistoryByTransactionIds(ids);
        return count;
    }

    /**
     * 根据id查询交易详细信息
     * @param id
     * @return
     */
    @Override
    public Transaction queryTransactionForDetailById(String id) {
        return transactionMapper.selectTransactionForDetailById(id);
    }

    /**
     * 根据stage分组查询交易数
     * @return
     */
    @Override
    public List<Funnel> queryCountOfTranGroupByStage() {
        return transactionMapper.selectCountOfTranGroupByStage();
    }

    /**
     * 创建交易历史，设置客户id
     * @param transaction
     * @param createHistory
     * @param sessionUserId
     */
    private void createHistoryAndSetCustomerId(Transaction transaction, Boolean createHistory, String sessionUserId) {
        if (createHistory) {
            //阶段更改，添加交易历史
            TransactionHistory history = new TransactionHistory();
            history.setId(UUIDUtil.uuidToStr());
            history.setStage(transaction.getStage());
            history.setMoney(transaction.getMoney());
            history.setExpectedDate(transaction.getExpectedDate());
            history.setCreateTime(DateUtil.parseDateToStr(new Date()));
            history.setCreateBy(sessionUserId);
            history.setTranId(transaction.getId());
            transactionHistoryMapper.insertTransactionHistory(history);
        }
        if (transaction.getCustomerId() != null && transaction.getCustomerId() != "") {
            String customerId = customerMapper.selectCustomerIdByName(transaction.getCustomerId());
            if (customerId == null || "".equals(customerId)) {//输入的客户是否存在
                //输入的客户不存在，创建新客户
                Customer customer = new Customer();
                customer.setId(UUIDUtil.uuidToStr());
                customer.setOwner(sessionUserId);
                customer.setName(transaction.getCustomerId());
                customer.setCreateBy(sessionUserId);
                customer.setCreateTime(DateUtil.parseDateToStr(new Date()));
                customerMapper.insertCustomer(customer);
                //将新创建的客户id保存至联系人信息中心
                transaction.setCustomerId(customer.getId());
            }else {
                //将查询到的客户id保存至联系人信息中
                transaction.setCustomerId(customerId);
            }
        }
    }
}
