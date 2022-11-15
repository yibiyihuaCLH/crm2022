package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.Clue;

import java.util.List;
import java.util.Map;

public interface ClueMapper {
    /**
     * 添加线索
     * @param clue
     * @return
     */
    int insertClue(Clue clue);

    /**
     * 根据条件地分页查询线索
     * @param map
     * @return
     */
    List<Clue> selectClueByConditionForPage(Map<String,Object> map);

    /**
     * 根据条件查询线索总条数
     * @param map
     * @return
     */
    int selectClueCountByCondition(Map<String,Object> map);

    /**
     * 根据ids删除线索
     * @param ids
     * @return
     */
    int deleteClueByIds(String[] ids);

    /**
     * 根据id查询线索
     * @param id
     * @return
     */
    public Clue selectClueById(String id);

    /**
     * 根据id更新线索
     * @param clue
     * @return
     */
    int updateClueById(Clue clue);

    /**
     * 根据id查询线索详情
     * @param id
     * @return
     */
    Clue selectClueForDetailById(String id);

    /**
     * 根据id删除线索
     * @param id
     * @return
     */
    int deleteClueById(String id);
}