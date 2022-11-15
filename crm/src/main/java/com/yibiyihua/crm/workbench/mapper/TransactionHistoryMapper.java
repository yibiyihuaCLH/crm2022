package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.TransactionHistory;

import java.util.List;

public interface TransactionHistoryMapper {
    /**
     * 根据交易ids删除交易历史
     * @param tranIds
     * @return
     */
    int deleteHistoryByTransactionIds(String[] tranIds);

    /**
     * 根据交易id查询交易阶段历史
     * @param tranId
     * @return
     */
    List<TransactionHistory> selectHistoryByTransactionId(String tranId);

    /**
     * 添加交易历史记录
     * @param tranHistory
     * @return
     */
    int insertTransactionHistory(TransactionHistory tranHistory);
}