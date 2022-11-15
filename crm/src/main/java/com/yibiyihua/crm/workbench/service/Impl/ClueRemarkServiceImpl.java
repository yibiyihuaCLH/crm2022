package com.yibiyihua.crm.workbench.service.Impl;

import com.yibiyihua.crm.workbench.bean.ClueRemark;
import com.yibiyihua.crm.workbench.mapper.ClueRemarkMapper;
import com.yibiyihua.crm.workbench.service.ClueRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/14 14:02
 * @description：线索备注业务逻辑层实现类
 * @modified By：
 * @version: 1.0
 */
@Service
public class ClueRemarkServiceImpl implements ClueRemarkService {
    @Autowired
    private ClueRemarkMapper clueRemarkMapper;

    /**
     * 根据线索id查询线索备注详细信息
     * @param clueId
     * @return
     */
    @Override
    public List<ClueRemark> queryClueRemarkFroDetailByClueId(String clueId) {
        return clueRemarkMapper.selectClueRemarkForDetailByClueId(clueId);
    }

    /**
     * 根据id删除线索
     * @param id
     * @return
     */
    @Override
    public int deleteClueRemarkById(String id) {
        return clueRemarkMapper.deleteClueRemarkById(id);
    }

    /**
     * 根据id保存编辑的线索
     * @param clueRemark
     * @return
     */
    @Override
    public int saveEditClueRemarkById(ClueRemark clueRemark) {
        return clueRemarkMapper.updateClueRemarkById(clueRemark);
    }

    /**
     * 保存创建的线索备注
     * @param clueRemark
     * @return
     */
    @Override
    public int saveCreateClueRemark(ClueRemark clueRemark) {
        return clueRemarkMapper.insertClueRemark(clueRemark);
    }


}
