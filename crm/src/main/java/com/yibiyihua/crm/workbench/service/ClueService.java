package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.Clue;

import java.util.List;
import java.util.Map;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/13 9:33
 * @description：线索业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface ClueService {
    /**
     * 添加线索
     * @param clue
     * @return
     */
    public int addClue(Clue clue);

    /**
     * 根据条件分页查询线索
     * @param map
     * @return
     */
    public List<Clue> queryClueByConditionForPage(Map<String,Object> map);

    /**
     * 根据条件查询线索总条数
     * @param map
     * @return
     */
    public int queryClueCountByCondition(Map<String,Object> map);

    /**
     * 根据ids删除线索
     * @param ids
     * @return
     */
    public int deleteClueByIds(String[] ids) throws Exception;

    /**
     * 根据id查询线索
     * @param id
     * @return
     */
    public Clue queryClueById(String id);

    /**
     * 根据id保存编辑的线索
     * @param clue
     * @return
     */
    public int saveEditClueById(Clue clue);

    /**
     * 通过id查询线索详细信息
     * @param id
     * @return
     */
    public Clue queryClueForDetailById(String id);

    /**
     * 保存线索转换
     * @param map
     */
    void saveClueConvert(Map<String,Object> map);
}
