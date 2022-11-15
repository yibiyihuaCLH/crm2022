package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.Funnel;
import com.yibiyihua.crm.workbench.bean.Transaction;
import com.yibiyihua.crm.workbench.bean.TransactionHistory;

import java.util.List;
import java.util.Map;

public interface TransactionMapper {
    /**
     * 添加交易记录
     * @param transaction
     * @return
     */
    int insertTransaction(Transaction transaction);

    /**
     * 根据客户id查询交易记录
     * @param customerId
     * @return
     */
    List<Transaction> selectTransactionByCustomerId(String customerId);

    /**
     * 根据客户ids删除客户交易
     * @param customerIds
     * @return
     */
    int deleteTransactionByCustomerIds(String[] customerIds);

    /**
     * 根据id删除交易
     * @param id
     * @return
     */
    int deleteTransactionById(String id);

    /**
     * 根据联系人id查询交易
     * @param contactsId
     * @return
     */
    List<Transaction> selectTransactionByContactsId(String contactsId);

    /**
     * 根据查询条件分页查询交易记录
     * @param map
     * @return
     */
    List<Transaction> selectTransactionByConditionForPage(Map<String, Object> map);

    /**
     * 根据查询条件查询中交易条数
     * @param map
     * @return
     */
    int selectCountByCondition(Map<String, Object> map);

    /**
     * 根据id查询交易信息
     * @param id
     * @return
     */
    Transaction selectTransactionById(String id);

    /**
     * 根据id保存编辑的交易记录
     * @param transaction
     * @return
     */
    int updateTransactionById(Transaction transaction);

    /**
     * 根据ids删除交易记录
     * @param ids
     * @return
     */
    int deleteTransactionByIds(String[] ids);

    /**
     * 根据id查询交易详细信息
     * @param id
     * @return
     */
    Transaction selectTransactionForDetailById(String id);

    /**
     * 更新交易阶段
     * @param transaction
     * @return
     */
    int updateTransactionStage(Transaction transaction);

    /**
     * 根据stage分组查询交易数
     * @return
     */
    List<Funnel> selectCountOfTranGroupByStage();
}