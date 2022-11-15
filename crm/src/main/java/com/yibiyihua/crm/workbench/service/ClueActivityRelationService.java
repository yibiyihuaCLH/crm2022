package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.ClueActivityRelation;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/15 17:38
 * @description：线索、市场活动关联业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface ClueActivityRelationService {
    /**
     * 增加线索、市场活动关联记录
     * @param clueActivityRelationList
     * @return
     */
    public int addCreateClueActivityRelation(List<ClueActivityRelation> clueActivityRelationList);

    /**
     * 根据线索id、市场活动id解雇关联
     * @param clueActivityRelation
     * @return
     */
    int deleteRelationshipByClueActivityId(ClueActivityRelation clueActivityRelation);

    /**
     * 根据线索id、市场活动id查询关联记录条数
     * @param clueActivityRelation
     * @return
     */
    int queryRelationshipCountByClueActivityId(ClueActivityRelation clueActivityRelation);
}
