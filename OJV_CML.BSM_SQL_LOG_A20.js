/*
 Navicat Premium Data Transfer

 Source Server         : mongodbforlog
 Source Server Type    : MongoDB
 Source Server Version : 30618 (3.6.18)
 Source Host           : 172.31.9.92:27017
 Source Schema         : mongodbforlog

 Target Server Type    : MongoDB
 Target Server Version : 30618 (3.6.18)
 File Encoding         : 65001

 Date: 11/11/2022 18:45:55
*/


// ----------------------------
// Collection structure for OJV_CML.BSM_SQL_LOG_A20
// ----------------------------
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").drop();
db.createCollection("OJV_CML.BSM_SQL_LOG_A20");
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    logBatchNo: NumberInt("-1"),
    sqlSequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_SQL_LOG_A20_BatchNo",
    background: true
});
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    docNo: NumberInt("-1"),
    sqlSequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_SQL_LOG_A20_docNo",
    background: true
});
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    waveNo: NumberInt("-1"),
    sqlSequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_SQL_LOG_A20_waveNo",
    background: true
});
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    mainTable: NumberInt("1"),
    sqlSequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_SQL_LOG_A20_mainTable",
    background: true
});
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    functionId: NumberInt("-1"),
    sqlSequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_SQL_LOG_A20_functionId",
    background: true
});
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    sqlSequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_SQL_LOG_A20_sqlSequence",
    background: true
});
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    userId: NumberInt("1"),
    sqlSequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_SQL_LOG_A20_userId",
    background: true
});
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    usedTime: NumberInt("-1"),
    sqlSequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_SQL_LOG_A20_usedTime",
    background: true
});
db.getCollection("OJV_CML.BSM_SQL_LOG_A20").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    logLevel: NumberInt("1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_SQL_LOG_A20_logLevel",
    background: true
});
