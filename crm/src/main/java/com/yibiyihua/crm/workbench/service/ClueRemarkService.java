package com.yibiyihua.crm.workbench.service;

import com.yibiyihua.crm.workbench.bean.ClueRemark;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/14 13:59
 * @description：线索备注业务逻辑层接口
 * @modified By：
 * @version: 1.0
 */
public interface ClueRemarkService {
    /**
     * 根据线索id查询线索备注详细信息
     * @param clueId
     * @return
     */
    public List<ClueRemark> queryClueRemarkFroDetailByClueId(String clueId);

    /**
     * 根据id删除线索
     * @param id
     * @return
     */
    public int deleteClueRemarkById(String id);

    /**
     * 根据id保存编辑的线索
     * @return
     */
    public int saveEditClueRemarkById(ClueRemark clueRemark);

    /**
     * 保存创建的线索备注
     * @param clueRemark
     * @return
     */
    public int saveCreateClueRemark(ClueRemark clueRemark);
}
