package com.yibiyihua.crm.commons.utils;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/10/7 9:38
 * @description：Excel工具类
 * @modified By：
 * @version: 1.0
 */
public class ExcelUtil {
    /**
     * 创建sheet单元格（给定下标和值即可）
     * @param sheet
     * @param rowIndex
     * @param columnIndex
     * @param value
     */
    public static void createCell(Sheet sheet,int rowIndex,int columnIndex,Object value) {
        Row row;
        if (sheet.getRow(rowIndex) == null) {
            row = sheet.createRow(rowIndex);
        }else {
            row = sheet.getRow(rowIndex);
        }
        Cell cell = row.createCell(columnIndex);
        if (value instanceof Double) {
            cell.setCellValue((double)value);
        } else if (value instanceof Date) {
            cell.setCellValue((Date) value);
        } else if (value instanceof Calendar) {
            cell.setCellValue((Calendar) value);
        } else if (value instanceof String) {
            cell.setCellValue((String) value);
        } else if (value instanceof RichTextString) {
            cell.setCellValue((RichTextString) value);
        } else if (value instanceof Boolean) {
            cell.setCellValue((boolean)value);
        }
    }

    /**
     * 将list中数据填充至某一行
     * @param sheet
     * @param rowIndex
     * @param values
     */
    public static void createCellOnRow(Sheet sheet, int rowIndex, List values){
        for (int i = 0; i < values.size(); i++) {
            createCell(sheet,rowIndex,i,values.get(i));
        }
    }

    /**
     * 设置excel列名（首行值）
     * @param sheet
     * @param values
     * @return
     */
    public static void setColumnName(Sheet sheet,List values) {
        createCellOnRow(sheet,0,values);

    }

    /**
     * 将Excel封装类发送至浏览器
     * @param excel
     * @param response
     * @throws IOException
     */
    public static void sendExcel(
            HSSFWorkbook excel,
            String name,
            HttpServletResponse response) throws IOException {
        //设置响应内容
        response.setContentType("application/octet-stream;charset=UTF-8");
        //设置响应头信息，使浏览器默认弹出文件下载窗口
        response.addHeader("Content-Disposition","attachment;filename = "+ URLEncoder.encode(name,"UTF-8") +".xls;");
        //获取响应输出流
        OutputStream out = response.getOutputStream();
        //将excel输出至浏览器
        excel.write(out);
        //关闭资源
        excel.close();
        out.flush();
    }

    /**
     * 获取单元格值
     * @param cell
     * @return
     */
    public static String getCellValue(Cell cell) {
        String cellValue = null;
        if (cell == null || cell.getCellType() == Cell.CELL_TYPE_BLANK) {
            cellValue = "";
        } else if (cell.getCellType() == Cell.CELL_TYPE_STRING) {
            cellValue = cell.getStringCellValue();
        } else if (cell.getCellType() == Cell.CELL_TYPE_BOOLEAN) {
            cellValue = String.valueOf(cell.getBooleanCellValue());
        } else if (cell.getCellType() == Cell.CELL_TYPE_NUMERIC) {
            cellValue = String.valueOf(cell.getNumericCellValue());
        } else if (cell.getCellType() == Cell.CELL_TYPE_ERROR) {
            cellValue = String.valueOf(cell.getErrorCellValue());
        }
        return cellValue;
    }
}
