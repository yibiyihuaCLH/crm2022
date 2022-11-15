package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.Transaction;
import com.yibiyihua.crm.workbench.bean.TransactionHistory;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/22 16:08
 * @description：交易历史业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface TransactionHistoryService {
    /**
     * 根据交易id查询交易阶段历史
     * @param tranId
     * @return
     */
    List<TransactionHistory> queryHistoryByTransactionId(String tranId);

    /**
     * 保存创建的历史记录
     * @param tranHistory
     * @return
     */
    int saveCreateTransactionHistory(TransactionHistory tranHistory, Transaction transaction);

}
