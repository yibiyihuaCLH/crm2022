package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityMapper {
    /**
     * 添加市场活动记录
     * @param activity
     * @return
     */
    int insertActivity(Activity activity);

    /**
     * 根据查询条件分页查询市场活动
     * @param map
     * @return
     */
    List<Activity> selectActivityByConditionForPage(Map<String,Object> map);

    /**
     * 根据查询条件查询市场活动记录条数
     * @param map
     * @return
     */
    int selectCountByCondition(Map<String,Object> map);

    /**
     * 根据ids批量删除市场活动
     * @param ids
     * @return
     */
    int deleteActivityByIds(String[] ids);

    /**
     * 根据id查询市场活动记录
     * @param id
     * @return
     */
    Activity selectActivityById(String id);

    /**
     * 根据id有选择得更新市场活动记录
     * @param activity
     * @return
     */
    int updateActivity(Activity activity);

    /**
     * 查询所有市场活动
     * @return
     */
    List<Activity> selectAllActivity();

    /**
     * 根据ids查询市场活动
     * @param ids
     * @return
     */
    List<Activity> selectActivityByIds(String[] ids);

    /**
     * 根据activityList添加市场活动
     * @param activityList
     * @return
     */
    int insertActivityByList(List<Activity> activityList);

    /**
     * 根据id查询市场活动详细信息
     * @param id
     * @return
     */
    Activity selectActivityForDetailById(String id);

    /**
     * 根据线索id查询相关联的市场活动
     * @param clueId
     * @return
     */
    List<Activity> selectActivityByClueId(String clueId);

    /**
     * 根据名称模糊查询未关联当前线索的市场活动
     * @param map
     * @return
     */
    List<Activity> selectActivityByNameWithoutRelation(Map<String,Object> map);

    /**
     * 根据名称模糊查询线索所关联的市场活动
     * @param map
     * @return
     */
    List<Activity> selectActivityByNameAndClueId(Map<String,Object> map);

    /**
     * 根据联系人id查询联系人关联的市场活动
     * @param contactsId
     * @return
     */
    List<Activity> selectActivityByContactsId(String contactsId);

    /**
     * 根据名称模糊查询市场活动
     * @param name
     * @return
     */
    List<Activity> selectActivityByNameLike(String name);
}
