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

 Date: 30/10/2022 00:29:22
*/


// ----------------------------
// Collection structure for OJV_CML.BSM_ACTIVITY_LOG
// ----------------------------
db.getCollection("OJV_CML.BSM_ACTIVITY_LOG").drop();
db.createCollection("OJV_CML.BSM_ACTIVITY_LOG");
db.getCollection("OJV_CML.BSM_ACTIVITY_LOG").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    sessionId: NumberInt("-1"),
    activitySequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_ACTIVITY_LOG_sessionId",
    background: true
});
db.getCollection("OJV_CML.BSM_ACTIVITY_LOG").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    activitySequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_ACTIVITY_LOG_activitySequence",
    background: true
});
db.getCollection("OJV_CML.BSM_ACTIVITY_LOG").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    userId: NumberInt("1"),
    activitySequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_ACTIVITY_LOG_userId",
    background: true
});
db.getCollection("OJV_CML.BSM_ACTIVITY_LOG").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    functionId: NumberInt("-1"),
    activitySequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_ACTIVITY_LOG_functionId",
    background: true
});
db.getCollection("OJV_CML.BSM_ACTIVITY_LOG").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    logBatchNo: NumberInt("-1"),
    activitySequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_ACTIVITY_LOG_BatchNo",
    background: true
});
db.getCollection("OJV_CML.BSM_ACTIVITY_LOG").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    usedTime: NumberInt("-1"),
    activitySequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_ACTIVITY_LOG_usedTime",
    background: true
});
db.getCollection("OJV_CML.BSM_ACTIVITY_LOG").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    pkey01: NumberInt("1"),
    activitySequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_ACTIVITY_LOG_pkey01",
    background: true
});
db.getCollection("OJV_CML.BSM_ACTIVITY_LOG").createIndex({
    bizWarehouseId: NumberInt("1"),
    subSystem: NumberInt("1"),
    codeValue: NumberInt("1"),
    activitySequence: NumberInt("-1"),
    addTime: NumberInt("-1")
}, {
    name: "I_BSM_ACTIVITY_LOG_codeValue",
    background: true
});
