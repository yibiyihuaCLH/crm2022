package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationMapper {

    /**
     * 增加线索、市场活动关联记录
     * @param clueActivityRelationList
     * @return
     */
    int insertCreateClueActivityRelation(List<ClueActivityRelation> clueActivityRelationList);

    /**
     * 根据线索id、市场活动id解除关联
     * @param clueActivityRelation
     * @return
     */
    int deleteRelationshipByClueActivityId(ClueActivityRelation clueActivityRelation);

    /**
     * 根据线索id、市场活动id查询关联记录条数
     * @param clueActivityRelation
     * @return
     */
    int selectRelationshipCountByClueActivityId(ClueActivityRelation clueActivityRelation);

    /**
     * 根据线索id查询线索、市场活动关联关系
     * @param clueId
     * @return
     */
    List<String> selectRelationShipByClueId(String clueId);

    /**
     * 根据线索id删除线索、市场活动关系
     * @param clueId
     * @return
     */
    int deleteRelationshipByClueId(String clueId);

    /**
     * 根据市场活动ids删除线索、市场活动关联关系
     * @param activityIds
     * @return
     */
    int deleteRelationshipByActivityIds(String[] activityIds);

    /**
     * 根据线索ids批量删除线索、市场活动关系
     * @param clueIds
     * @return
     */
    int deleteRelationshipByClueIds(String[] clueIds);
}