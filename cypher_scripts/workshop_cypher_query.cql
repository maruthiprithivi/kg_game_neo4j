////////////////////////////////////////////////////////////////////////////////////////
// Created On: 14-07-2021
// Updaed On: 04-06-2022
// Version: 1.0.3
// Created By: Maruthi Pritivirajan
// Updated By: Maruthi Pritivirajan
// Description: This file contains Cypher scripts to explore and load data into Neo4j 
// to build a simple Social Network Graph used to understand what a Knowledge Graph is.
////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
//// Explore the data sets
////////////////////////////////////////////////////////////////////////////////////////

// Check education data set
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_education.csv' AS row
RETURN row limit 5;

// Check employment data set
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_work.csv' AS row
RETURN row limit 5;

// Check travel data set
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_trips.csv' AS row
RETURN row limit 5;

// Check bank card transactions data set
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_transaction.csv' AS row
RETURN row limit 5;


////////////////////////////////////////////////////////////////////////////////////////
//// Build the Knowledge Graph!!
////////////////////////////////////////////////////////////////////////////////////////

// It's best practice to add constraints and indexes in your database before loading data into Neo4j.

// Create Constraints and verify the constraints
CREATE CONSTRAINT personPassportNumberConstraint IF NOT EXISTS FOR (p:Person) REQUIRE p.passportnumber IS UNIQUE;
CREATE CONSTRAINT countryNameConstraint IF NOT EXISTS FOR (c:Country) REQUIRE c.name IS UNIQUE;
CREATE CONSTRAINT institutionNameConstraint IF NOT EXISTS FOR (i:Institution) REQUIRE i.name IS UNIQUE;
CREATE CONSTRAINT merchantNameConstraint IF NOT EXISTS FOR (m:Merchant) REQUIRE m.name IS UNIQUE;
SHOW CONSTRAINTS;

// Create Index and verify the index
CREATE INDEX organizationNameConstraint IF NOT EXISTS FOR (o:Organization) ON o.organization;
SHOW INDEXES;

// Load education data
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_education.csv' AS row
MERGE (person:Person {passportnumber: row.passportnumber})
  ON CREATE SET 
    person.name = row.name
MERGE (institution:Institution {name: row.nameofinstitution})
MERGE (country:Country {name: row.country})
CREATE (course:Course {name: row.course})
MERGE (person)-[:STUDIED_AT]->(institution)
MERGE (institution)<-[:FROM]-(course)
MERGE (country)<-[:FROM]-(institution)
MERGE (course)<-[:MATRICULATED {year:row.startyear}]-(person)-[:GRADUATED {year:row.endyear}]->(course);

// Check the Graph Schema
CALL db.schema.visualization

// Verify education data load
MATCH (n) RETURN LABELS(n) as node_labels, COUNT(n) as node_count;

// Load employment data
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_work.csv' AS row
MERGE (organization:Organization {designation: row.designation, organization: row.nameoforganization, startyear: row.startyear, endyear: row.endyear})
MERGE (country:Country {name: row.country})
WITH organization, country, row
MATCH (person:Person {passportnumber: row.passportnumber})
MERGE (person)-[:EMPLOYED]->(organization);

// Check the Graph Schema
CALL db.schema.visualization

// Verify employment data load
MATCH (n) RETURN LABELS(n) as node_labels, COUNT(n) as node_count;

// Load travel data
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_trips.csv' AS row
MERGE (citizenship:Country {name: row.citizenship})
MERGE (arrival:Country {name: row.arrivalcountry})
WITH  citizenship, arrival, row
MATCH (person:Person {passportnumber: row.passportnumber})
MERGE (person)-[:TRAVELLED {departuredate: row.departuredate, arrivaldate: row.arrivaldate}]->(arrival)
MERGE (person)-[:CITIZEN_OF]->(citizenship);

// Check the Graph Schema
CALL db.schema.visualization

// Verify travel data load
MATCH (n) RETURN LABELS(n) as node_labels, COUNT(n) as node_count;

// Load bank card transaction data
LOAD CSV WITH HEADERS FROM 'https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_transaction.csv' AS row
MERGE (card:Card {cardnumber: row.cardnumber})
MERGE (country:Country {name: row.country})
MERGE (merchant:Merchant {name: row.merchant})
WITH card, country, merchant, row
MATCH (person:Person {passportnumber: row.passportnumber})
MERGE (person)-[:HAS_CARD]->(card)
MERGE (merchant)<-[:TRANSACTED {amount: row.amount, transactiondate: row.transactiondate}]-(card)
MERGE (transaction)-[:FROM]->(merchant);

// Check the Graph Schema
CALL db.schema.visualization

// Verify bank card transaction data load
MATCH (n) RETURN LABELS(n) as node_labels, COUNT(n) as node_count;

////////////////////////////////////////////////////////////////////////////////////////
//// Explore the Knowledge Graph!!
////////////////////////////////////////////////////////////////////////////////////////

//// Basic information retrieval from the Graph 

// Retrieve Nodes/Vertex of a specific "Label"
// Retrieve all Person Node
MATCH (p:Person) RETURN p;

// Retrieve specific properties of a Node/Vertex
// Retrieve name and passport number of Person Nodes
MATCH (p:Person) RETURN p.name as Name, p.passportnumber as `Passport Number`;

// Retrieve a specific Node/Vertex using a specific property
// Retrieve a Person Node with a specific passport number
MATCH (p:Person {passportnumber: "GHI5678JKL"}) RETURN p;

// Rerieve Relationship/Edge of a specific "Type"
// Retrieve all "EMPLOYED" Relationship/Edge | Since Relationships/Edges can only exist between two Nodes/Vertices
// we will also retrieve the Nodes/Vertices that are connected to the Relationship/Edge
MATCH (p)-[r:EMPLOYED]->(o) RETURN p, r, o; 

// Retrieve specific properties of a Relationship/Edge
// Retrieve the arrival and departure dates of the "TRAVELLED" Relationship/Edge
MATCH ()-[r:TRAVELLED]->() RETURN r.arrivaldate as `Arrival Date`, r.departuredate as `Departure Date`;

//// Now on to doing Graph Traversals 

// Traverse the Graph using a specific Node/Vertex Label as the starting point and retrieve 
// all the Nodes/Vertices that are connected to it by One Degree away.
// Retreive all the "Institution" Nodes that are 
MATCH (i:Institution)-[r]-(n) RETURN i, r, n;
// You might have noticed that there are a lot more Relationships/Vertices that are connecting 
// the First degree Nodes/Vertices of the "Institution" Nodes 

// When you are doing Graph Traversals, you can also specify the direction and the path of the Traversal
// Perform a direction specific traversal from the "Institution" Nodes
MATCH (i:Institution)-[r]->(n) RETURN i, r, n;

// Perform a Relationship/Vertex type specific traversal from the "Institution" Nodes
MATCH (i:Institution)-[r:STUDIED_AT]-(n) RETURN i, r, n;

//// Now your turn to explore the Graph using Cypher Queries!
//// Happy traversal!