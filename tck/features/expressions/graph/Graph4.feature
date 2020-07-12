#
# Copyright (c) 2015-2020 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Attribution Notice under the terms of the Apache License 2.0
#
# This work was created by the collective efforts of the openCypher community.
# Without limiting the terms of Section 6, any Derivative Work that is not
# approved by the public consensus process of the openCypher Implementers Group
# should not be described as “Cypher” (and Cypher® is a registered trademark of
# Neo4j Inc.) or as "openCypher". Extensions by implementers or prototypes or
# proposals for change that have been documented or implemented should only be
# described as "implementation extensions to Cypher" or as "proposed changes to
# Cypher that are not yet approved by the openCypher community".
#

#encoding: utf-8

Feature: Graph4 - Edge relationship type

  Scenario: `type()`
    Given an empty graph
    And having executed:
      """
      CREATE ()-[:T]->()
      """
    When executing query:
      """
      MATCH ()-[r]->()
      RETURN type(r)
      """
    Then the result should be, in any order:
      | type(r) |
      | 'T'     |
    And no side effects

  Scenario: `type()` on two relationships
    Given an empty graph
    And having executed:
      """
      CREATE ()-[:T1]->()-[:T2]->()
      """
    When executing query:
      """
      MATCH ()-[r1]->()-[r2]->()
      RETURN type(r1), type(r2)
      """
    Then the result should be, in any order:
      | type(r1) | type(r2) |
      | 'T1'     | 'T2'     |
    And no side effects

  Scenario: `type()` on null relationship
    Given an empty graph
    And having executed:
      """
      CREATE ()
      """
    When executing query:
      """
      MATCH (a)
      OPTIONAL MATCH (a)-[r:NOT_THERE]->()
      RETURN type(r)
      """
    Then the result should be, in any order:
      | type(r) |
      | null    |
    And no side effects

  Scenario: `type()` on mixed null and non-null relationships
    Given an empty graph
    And having executed:
      """
      CREATE ()-[:T]->()
      """
    When executing query:
      """
      MATCH (a)
      OPTIONAL MATCH (a)-[r:T]->()
      RETURN type(r)
      """
    Then the result should be, in any order:
      | type(r) |
      | 'T'     |
      | null    |
    And no side effects

  Scenario: `type()` handling Any type
    Given an empty graph
    And having executed:
      """
      CREATE ()-[:T]->()
      """
    When executing query:
      """
      MATCH (a)-[r]->()
      WITH [r, 1] AS list
      RETURN type(list[0])
      """
    Then the result should be, in any order:
      | type(list[0]) |
      | 'T'           |
    And no side effects

  @NegativeTest
  Scenario Outline: `type()` failing on invalid arguments
    Given an empty graph
    And having executed:
      """
      CREATE ()-[:T]->()
      """
    When executing query:
      """
      MATCH p = (n)-[r:T]->()
      RETURN [x IN [r, <invalid>] | type(x) ] AS list
      """
    Then a TypeError should be raised at runtime: InvalidArgumentValue

    Examples:
      | invalid |
      | 0       |
      | 1.0     |
      | true    |
      | ''      |
      | []      |
