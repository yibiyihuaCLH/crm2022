package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.Transaction;
import com.yibiyihua.crm.workbench.bean.TransactionHistory;
import com.yibiyihua.crm.workbench.mapper.TransactionHistoryMapper;
import com.yibiyihua.crm.workbench.mapper.TransactionMapper;
import com.yibiyihua.crm.workbench.service.TransactionHistoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/22 16:08
 * @description：交易历史业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class TransactionHistoryServiceImpl implements TransactionHistoryService {
    @Autowired
    private TransactionHistoryMapper transactionHistoryMapper;
    @Autowired
    private TransactionMapper transactionmapper;

    /**
     * 根据交易id查询交易阶段历史
     * @param tranId
     * @return
     */
    @Override
    public List<TransactionHistory> queryHistoryByTransactionId(String tranId) {
       return transactionHistoryMapper.selectHistoryByTransactionId(tranId);
    }

    /**
     * 保存创建的历史记录
     * @param tranHistory
     * @return
     */
    @Override
    public int saveCreateTransactionHistory(TransactionHistory tranHistory,Transaction transaction) {
        //更新交易状态
        transactionmapper.updateTransactionStage(transaction);
        return transactionHistoryMapper.insertTransactionHistory(tranHistory);
    }
}
