package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.ClueActivityRelation;
import com.yibiyihua.crm.workbench.mapper.ClueActivityRelationMapper;
import com.yibiyihua.crm.workbench.service.ClueActivityRelationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/15 17:40
 * @description：线索、市场活动关联业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class ClueActivityRelationServiceImpl implements ClueActivityRelationService {
    @Autowired
    private ClueActivityRelationMapper clueActivityRelationMapper;

    /**
     * 增加线索、市场活动关联记录
     * @param clueActivityRelationList
     * @return
     */
    @Override
    public int addCreateClueActivityRelation(List<ClueActivityRelation> clueActivityRelationList) {
        return clueActivityRelationMapper.insertCreateClueActivityRelation(clueActivityRelationList);
    }

    /**
     * 根据线索id、市场活动id解雇关联
     * @param clueActivityRelation
     * @return
     */
    @Override
    public int deleteRelationshipByClueActivityId(ClueActivityRelation clueActivityRelation) {
        return clueActivityRelationMapper.deleteRelationshipByClueActivityId(clueActivityRelation);
    }

    /**
     * 根据线索id、市场活动id查询关联记录条数
     * @param clueActivityRelation
     * @return
     */
    @Override
    public int queryRelationshipCountByClueActivityId(ClueActivityRelation clueActivityRelation) {
        return clueActivityRelationMapper.selectRelationshipCountByClueActivityId(clueActivityRelation);
    }
}
