<?php

require 'vendor/autoload.php';

$hosts = [
    '10.0.3.114:9200',
];

$clientBuilder = Elasticsearch\ClientBuilder::create();
$clientBuilder->setHosts($hosts);
$client = $clientBuilder->build();

$id = "9458682";
$params_events = [
    'index' => 'mlb',
    'type' => 'events',
    //'body' => ['id' => $id]
    'fields' => ['eventDateLocal','ticketInfo.minPrice', 
    'ticketInfo.maxPrice', 'ticketInfo.totalTickets',
    'ticketInfo.popularity','ticketInfo.currencyCode',
    'ticketInfo.minListPrice','ticketInfo.maxListPrice',
    'date_scrap', 'id'],
    "size" => 100
];

$params_venues = [
    'index' => 'mlb',
    'type' => 'venues',
    //'body' => ['id' => $id],
    'fields' => ['date_scrap', 'eventId'],
    "size" => 100
];


$params_events['body']['query']['match']['id'] = $id;
//$params_venues['body']['query']['match']['eventId'] = $id;

// $params_events['body']['query']['filtered']['filter']['and'][]['range']['date_scrap'] = [
// 	"gte" => "11-02-2016",
//     "lte" =>  "20-02-2016",
//     "format" => "dd-MM-yyyy"
// ];

// $params_venues['body']['query']['filtered']['filter']['and'][]['range']['date_scrap'] = [
// 	"gte" => "10-02-2016",
//     "lte" =>  "24-02-2016",
//     "format" => "dd-MM-yyyy"
// ];

$response = $client->search($params_events);

 var_dump($response);
 $result = $response["hits"]["hits"];


 foreach ($result as $key => $value) {
 	//print $result[$key]['fields']['date_scrap'][0]."\n";
 	// print $result[$key]['fields']['ticketInfo.minPrice'][0]."\n";
 	// print $result[$key]['fields']['ticketInfo.maxPrice'][0]."\n";
 	// print $result[$key]['fields']['ticketInfo.popularity'][0]."\n";
 	// print $result[$key]['fields']['ticketInfo.totalTickets'][0]."\n";
 	//print $result[$key]['fields']['eventId'][0]."\n";
 }

?>