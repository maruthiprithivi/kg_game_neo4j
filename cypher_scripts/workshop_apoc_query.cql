////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// Work In Progress /////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
// Created On: 14-07-2021
// Updaed On: 
// Version: 1.0.0
// Created By: Maruthi Pritivirajan
// Updated By: Maruthi Pritivirajan
// Description: This file contains APOC + Cypher scripts to explore and load data into Neo4j 
// to build a simple Social Network Graph used to understand what a Knowledge Graph is.
////////////////////////////////////////////////////////////////////////////////////////

// Load education data
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_education.csv') YIELD map RETURN map", 
    "MERGE (person:Person {passportnumber: map.passportnumber})
        ON CREATE SET 
            person.name = map.name
    MERGE (institution:Institution {name: map.nameofinstitution})
    MERGE (country:Country {name: map.country})
    CREATE (course:Course {name: map.course})
    MERGE (person)-[:STUDIED_AT]->(institution)
    MERGE (institution)<-[:FROM]-(course)
    MERGE (course)<-[:MATRICULATED {year:map.startyear}]-(person)-[:GRADUATED {year:map.endyear}]->(course)",
    {batchSize:3,parallel:False}
)
YIELD batches, total, committedOperations, failedOperations, errorMessages, wasTerminated
RETURN batches, total, committedOperations, failedOperations, errorMessages, wasTerminated;

// Load credit card transaction data
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_transaction.csv') YIELD map RETURN map", 
    "MERGE (card:Card {cardnumber: map.cardnumber})
    MERGE (country:Country {name: map.country})
    MERGE (merchant:Merchant {name: map.merchant})
    CREATE (transaction:Transaction {amount: map.amount, transactiondate: map.transactiondate})
    WITH card, country, merchant, transaction, map
    MATCH (person:Person {passportnumber: map.passportnumber})
    MERGE (person)-[:HAS_CARD]->(card)
    MERGE (transaction)<-[:TRANSACTED]-(card)
    MERGE (transaction)-[:FROM]->(merchant)
    MERGE (merchant)-[:FROM]->(country)",
    {batchSize:3,parallel:False}
)
YIELD batches, total, committedOperations, failedOperations, errorMessages, wasTerminated
RETURN batches, total, committedOperations, failedOperations, errorMessages, wasTerminated;

// Load travel data
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_trips.csv') YIELD map RETURN map", 
    "MERGE (citizenship:Country {name: map.citizenship})
    MERGE (country:Country {name: map.arrivalcountry})
    WITH citizenship, map
    MATCH (person:Person {passportnumber: map.passportnumber})
    MERGE (person)-[:TRAVELLED {arrivaldate: map.arrivaldate, departuredate: map.departuredate}]->(country)
    MERGE (person)-[:CITIZEN_OF]->(citizenship)",
    {batchSize:3,parallel:False}
)
YIELD batches, total, committedOperations, failedOperations, errorMessages, wasTerminated
RETURN batches, total, committedOperations, failedOperations, errorMessages, wasTerminated;

// CALL apoc.periodic.iterate(
//     "CALL apoc.load.csv('https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_trips.csv') YIELD map RETURN map", 
//     "CREATE (trip:Trip {departuredate: map.departuredate, arrivaldate: map.arrivaldate})
//     MERGE (citizenship:Country {name: map.citizenship})
//     MERGE (arrival:Country {name: map.arrivalcountry})
//     MERGE (departure:Country {name: map.departurecountry})
//     WITH trip, citizenship, arrival, departure, map
//     MATCH (person:Person {passportnumber: map.passportnumber})
//     MERGE (person)-[:TRAVELLED]->(trip)
//     MERGE (trip)-[:DEPARTED]->(departure)
//     MERGE (trip)-[:ARRIVED]->(arrival)
//     MERGE (person)-[:CITIZEN_OF]->(citizenship)",
//     {batchSize:3,parallel:False}
// )
// YIELD batches, total, committedOperations, failedOperations, errorMessages, wasTerminated
// RETURN batches, total, committedOperations, failedOperations, errorMessages, wasTerminated;

// Load employment data
CALL apoc.periodic.iterate(
    "CALL apoc.load.csv('https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_work.csv') YIELD map RETURN map", 
    "MERGE (organization:Organization {name: map.nameoforganization})
    SET organization.worked_as = map.designation, organization.start_year = map.startyear, organization.end_year = map.endyear
    MERGE (country:Country {name: map.country})
    WITH organization, country, map
    MATCH (person:Person {passportnumber: map.passportnumber})
    MERGE (person)-[:WORKED_AT]->(organization)
    MERGE (organization)-[:HAS_DESIGNATION]->(designation)",
    {batchSize:3,parallel:False}
)
YIELD batches, total, committedOperations, failedOperations, errorMessages, wasTerminated
RETURN batches, total, committedOperations, failedOperations, errorMessages, wasTerminated;

// CALL apoc.periodic.iterate(
//     "CALL apoc.load.csv('https://gist.githubusercontent.com/maruthiprithivi/10b456c74ba99a35a52caaffafb9d3dc/raw/a46af9c6c4bf875ded877140c112e9ff36f8f2e8/sng_work.csv') YIELD map RETURN map", 
//     "MERGE (organization:Organization {name: map.nameoforganization})
//     CREATE (employment:Employment {startyear: map.startyear, endyear: map.endyear})
//     MERGE (designation:Designation {name: map.designation})
//     MERGE (country:Country {name: map.country})
//     WITH organization, designation, employment, country, map
//     MATCH (person:Person {passportnumber: map.passportnumber})
//     MERGE (person)-[:EMPLOYED]->(employment)
//     MERGE (employment)-[:WORKED_AT]->(organization)
//     MERGE (employment)-[:WORKED_AS]->(designation)
//     MERGE (organization)-[:HAS_DESIGNATION]->(designation)",
//     {batchSize:3,parallel:False}
// )
// YIELD batches, total, committedOperations, failedOperations, errorMessages, wasTerminated
// RETURN batches, total, committedOperations, failedOperations, errorMessages, wasTerminated;