package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.Funnel;
import com.yibiyihua.crm.workbench.bean.Transaction;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/19 14:39
 * @description：交易业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface TransactionService {

    /**
     * 根据客户id查询关联交易
     * @param customerId
     * @return
     */
    List<Transaction> queryTransactionByCustomerId(String customerId);

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
    List<Transaction> queryTransactionByContactsId(String contactsId);

    /**
     * 根据查询条件分页查询交易记录
     * @param map
     * @return
     */
    List<Transaction> queryTransactionByConditionForPage(Map<String, Object> map);

    /**
     * 根据查询条件查询中交易条数
     * @param map
     * @return
     */
    int queryCountByCondition(Map<String, Object> map);

    /**
     * 保存创建的交易
     * @param transaction
     * @param sessionUserId
     * @return
     */
    int saveCreateTransaction(Transaction transaction, String sessionUserId);

    /**
     * 根据id查询交易信息
     * @param id
     * @return
     */
    Transaction queryTransactionById(String id);

    /**
     * 根据id保存编辑的交易记录
     * @param transaction
     * @param sessionUserId
     * @return
     */
    int saveEditTransactionById(Transaction transaction,Boolean createHistory,String sessionUserId);

    /**
     * 根据ids删除交易记录
     * @param ids
     * @return
     */
    int deleteTransactionByIds(String[] ids) throws Exception;

    /**
     * 根据id查询交易详细信息
     * @param id
     * @return
     */
    Transaction queryTransactionForDetailById(String id);

    /**
     * 根据stage分组查询交易数
     * @return
     */
    List<Funnel> queryCountOfTranGroupByStage();
}
