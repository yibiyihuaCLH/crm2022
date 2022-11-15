package com.yibiyihua.crm.workbench.mapper;

import com.yibiyihua.crm.workbench.bean.ClueRemark;

import java.util.List;

public interface ClueRemarkMapper {
    /**
     * 根据线索id查询线索备注详细信息
     * @param clueId
     * @return
     */
    List<ClueRemark> selectClueRemarkForDetailByClueId(String clueId);

    /**
     * 根据id删除线索
     * @param id
     * @return
     */
    int deleteClueRemarkById(String id);

    /**
     * 根据id更新线索
     * @param clueRemark
     * @return
     */
    int updateClueRemarkById(ClueRemark clueRemark);

    /**
     * 添加线索备注
     * @param clueRemark
     * @return
     */
    int insertClueRemark(ClueRemark clueRemark);

    /**
     * 根据线索id查询线索备注
     * @param clueId
     * @return
     */
    List<ClueRemark> selectClueRemarkByClueId(String clueId);

    /**
     * 根据线索id删除线索备注
     * @param clueId
     * @return
     */
    int deleteClueRemarkByClueId(String clueId);

    /**
     * 根据线索id批量删除线索备注
     * @param clueIds
     * @return
     */
    int deleteClueRemarkByClueIds(String[] clueIds);
}