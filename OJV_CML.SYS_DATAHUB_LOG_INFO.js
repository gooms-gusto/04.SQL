/*
 Navicat Premium Data Transfer

 Source Server         : CML DATAHUB MONGO
 Source Server Type    : MongoDB
 Source Server Version : 30618
 Source Host           : 172.31.9.92:27017
 Source Schema         : datahubmongo

 Target Server Type    : MongoDB
 Target Server Version : 30618
 File Encoding         : 65001

 Date: 03/02/2023 10:15:36
*/


// ----------------------------
// Collection structure for OJV_CML.SYS_DATAHUB_LOG_INFO
// ----------------------------
db.getCollection("OJV_CML.SYS_DATAHUB_LOG_INFO").drop();
db.createCollection("OJV_CML.SYS_DATAHUB_LOG_INFO");
db.getCollection("OJV_CML.SYS_DATAHUB_LOG_INFO").createIndex({
    messageGroupSysId: NumberInt("-1"),
    addTimeIndex: NumberInt("-1")
}, {
    name: "ix_OJV_CML.SYS_DATAHUB_LOG_INFO",
    background: true
});
