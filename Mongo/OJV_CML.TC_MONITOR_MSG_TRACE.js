/*
 Navicat Premium Data Transfer

 Source Server         : DATAHUB WMS MONGO
 Source Server Type    : MongoDB
 Source Server Version : 30618
 Source Host           : 172.31.9.92:27017
 Source Schema         : datahubmongo

 Target Server Type    : MongoDB
 Target Server Version : 30618
 File Encoding         : 65001

 Date: 30/10/2023 09:25:47
*/


// ----------------------------
// Collection structure for OJV_CML.TC_MONITOR_MSG_TRACE
// ----------------------------
db.getCollection("OJV_CML.TC_MONITOR_MSG_TRACE").drop();
db.createCollection("OJV_CML.TC_MONITOR_MSG_TRACE");
db.getCollection("OJV_CML.TC_MONITOR_MSG_TRACE").createIndex({
    messageGroupSysId: NumberInt("-1")
}, {
    name: "ix_OJV_CML.TC_MONITOR_MSG_TRACE",
    background: true
});
db.getCollection("OJV_CML.TC_MONITOR_MSG_TRACE").createIndex({
    organizationId: NumberInt("1"),
    datahubCustomerId: NumberInt("1"),
    messageId: NumberInt("1"),
    addTimeIndex: NumberInt("1"),
    _shardKey: NumberInt("1")
}, {
    name: "ix_archive",
    background: true
});
