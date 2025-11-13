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

 Date: 04/03/2023 06:24:40
*/


// ----------------------------
// Collection structure for OJV_CML.TC_MONITOR_RECEIVE_HEADER
// ----------------------------
db.getCollection("OJV_CML.TC_MONITOR_RECEIVE_HEADER").drop();
db.createCollection("OJV_CML.TC_MONITOR_RECEIVE_HEADER");
db.getCollection("OJV_CML.TC_MONITOR_RECEIVE_HEADER").createIndex({
    organizationId: NumberInt("1"),
    datahubCustomerId: NumberInt("1"),
    messageId: NumberInt("1"),
    reprocessFlag: NumberInt("1"),
    reprocessTime: NumberInt("-1")
}, {
    name: "ix_reprocess_OJV_CML.TC_MONITOR_RECEIVE_HEADER",
    background: true
});
db.getCollection("OJV_CML.TC_MONITOR_RECEIVE_HEADER").createIndex({
    messageGroupSysId: NumberInt("-1"),
    addTimeIndex: NumberInt("-1")
}, {
    name: "ix_OJV_CML.TC_MONITOR_RECEIVE_HEADER",
    background: true
});
