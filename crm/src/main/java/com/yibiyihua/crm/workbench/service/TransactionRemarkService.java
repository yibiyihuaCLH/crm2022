package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.TransactionRemark;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/22 15:47
 * @description：交易备注业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface TransactionRemarkService {
    /**
     * 根据交易id查询交易备注
     * @param tranId
     * @return
     */
    List<TransactionRemark> queryRemarkByTransactionId(String tranId);

    /**
     * 保存创建的交易备注
     * @param transactionRemark
     * @return
     */
    int saveCreateTransactionRemark(TransactionRemark transactionRemark);

    /**
     * 根据id删除交易备注
     * @param id
     * @return
     */
    int deleteTransactionRemarkById(String id);

    /**
     * 根据id保存编辑的文本内容
     * @param transactionRemark
     * @return
     */
    int saveEditTransactionRemarkById(TransactionRemark transactionRemark);
}
