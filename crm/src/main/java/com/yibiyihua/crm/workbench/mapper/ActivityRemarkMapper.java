package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.ActivityRemark;

import java.util.List;

public interface ActivityRemarkMapper {
    /**
     * 根据市场活动id查询市场活动备注详细信息
     * @param activityId
     * @return
     */
    List<ActivityRemark> selectActivityRemarkForDetailByActivityId(String activityId);

    /**
     * 增加市场活动备注
     * @param activityRemark
     * @return
     */
    int insertActivityRemark(ActivityRemark activityRemark);

    /**
     * 根据id删除市场活动备注
     * @param id
     * @return
     */
    int deleteActivityRemarkById(String id);

    /**
     *根据id更新市场活动备注
     * @param activityRemark
     * @return
     */
    int updateActivityRemarkById(ActivityRemark activityRemark);

    /**
     *根据id查询市场活动备注
     * @param id
     * @return
     */
    ActivityRemark selectActivityRemarkById(String id);

    /**
     * 根据市场活动ids删除市场活动备注
     * @param activityIds
     * @return
     */
    int deleteActivityRemarkByActivityIds(String[] activityIds);
}