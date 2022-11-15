package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.TransactionRemark;

import java.util.List;

public interface TransactionRemarkMapper {
    /**
     * 批量添加交易备注
     * @param transactionRemarkList
     * @return
     */
    int insertTransactionRemarkByList(List<TransactionRemark> transactionRemarkList);

    /**
     * 根据交易ids删除交易备注
     * @param transactionIds
     * @return
     */
    int deleteRemarkByTransactionIds(String[] transactionIds);

    /**
     * 根据交易id查询交易备注
     * @param tranId
     * @return
     */
    List<TransactionRemark> selectRemarkByTransactionId(String tranId);

    /**
     * 添加交易备注
     * @param transactionRemark
     * @return
     */
    int insertTransactionRemark(TransactionRemark transactionRemark);

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
    int updateTransactionRemarkById(TransactionRemark transactionRemark);
}