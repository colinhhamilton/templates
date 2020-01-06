<#ftl encoding="utf-8" />
<#import "/web/templates/modernui/funnelback_classic.ftl" as s/>
<#import "/web/templates/modernui/funnelback.ftl" as fb/>
<#-- 

  This template provides a cut down JSON response of the data model. 

  The collection.cfg should have the following parameters defined:
  * ui.modern.click_link_json=
  * ui.modern.search_link_json=/s/search.html
  * ui.modern.form.json.content_type=application/json

#-->

<#-- Print the JSON with the callback parameter -->
<#macro JSON>
   <#compress>
      <@Callback>
         <@CreateJSON />
      </@Callback>
   </#compress>
</#macro>

<#-- Append the callback variable if it exists -->
<#macro Callback>
   <#if question.inputParameterMap["callback"]?exists>
      ${question.inputParameterMap["callback"]?json_string} (<#nested> )
   <#else>
      <#nested>
   </#if>
</#macro>

<#-- Create the JSON from just the results -->
<#macro CreateJSON>
  {  
    "question" :
      {
          "query" : "${question.query!?json_string}",
          "selectedFacets"    :   [
            <#if (question.selectedFacets)!?has_content>
              <#list question.selectedFacets as selectedFacets>
                "${selectedFacets?json_string}"
                <#-- Insert comma if there are more items -->
                <#if selectedFacets_has_next>,</#if>
              </#list>
            </#if>
          
            ] ,
          <@SelectedFacetValues />
      },
    "response" :
      {
        <@ResultSummary />,
        <@Spelling />,
        "results":
        [
          <#if (response.resultPacket.results)!?has_content>
            <#list response.resultPacket.results as result>
              <#if result.class.simpleName?upper_case != "TIERBAR"> 
                {
                   "rank" : ${result.rank?c},
                   "score" : ${result.score?c},
                   "title" : "${result.title?json_string?split("|")[0]}",
                   "liveUrl" : "${result.liveUrl?json_string}",
                   "displayUrl" : "${result.displayUrl?json_string}",
                   "clickTrackingUrl" : "${question.collection.configuration.value("ui.modern.click_link_json")!?json_string}${result.clickTrackingUrl?json_string}",
                   "summary" : "${result.summary!?json_string}",
                   "fileSize" : ${result.fileSize?c},
                   "fileType" : "${result.fileType?json_string}",
                   <@MetaDataJSON result />
                }
                <#-- Insert comma if there are more items -->
                <#if result_has_next>,</#if>
              </#if>
            </#list>
          </#if>
        ],
        <@Facets />,
        <@Curator />,
        "QueryString" : "${QueryString?json_string}"
      }
  }
</#macro>

<#-- Displays the summary of the search such as total matching -->
<#macro ResultSummary>
   <#if (response.resultPacket.resultsSummary)!?has_content && (response.resultPacket.results)!?has_content > 
      "resultsSummary" : 
      {
         "fullyMatching" : ${response.resultPacket.resultsSummary.fullyMatching?c},       
         "partiallyMatching" : ${response.resultPacket.resultsSummary.partiallyMatching?c},
         "totalMatching" : ${response.resultPacket.resultsSummary.totalMatching?c},
         "numRanks" : ${response.resultPacket.resultsSummary.numRanks?c},
         "currStart" : ${response.resultPacket.resultsSummary.currStart?c},
         "currEnd" : ${response.resultPacket.resultsSummary.currEnd?c},
         "prevStart" : <#if (response.resultPacket.resultsSummary.prevStart)!?has_content>${response.resultPacket.resultsSummary.prevStart?c}<#else>null</#if>, 
         "nextStart" : <#if (response.resultPacket.resultsSummary.nextStart)!?has_content>${response.resultPacket.resultsSummary.nextStart?c}<#else>null</#if>
      }
   <#else>
      "resultsSummary" : 
      {
         "fullyMatching" : 0,
         "partiallyMatching" : 0,
         "totalMatching" : 0,
         "numRanks" : 0,
         "currStart" : 0,
         "currEnd" : 0,
         "prevStart" : 0,
         "nextStart" : 0
      }   
   </#if>
</#macro>

<#-- Create the json for the meta data section --> 
<#macro MetaDataJSON result>
   "metaData" : 
   {
      <#list result.metaData?keys as key>
     <#if key = "s">"keywords"
	 <#else> "${key?json_string}"
	 </#if> : "${result.metaData[key]?json_string}"
         <#if key_has_next>,</#if>
      </#list>
   }
</#macro>

<#-- Create the json for the spellings --> 
<#macro Spelling>
   "spell" : 
   {
     <#if (response.resultPacket.spell)!?has_content>
      "url" : "${question.collection.configuration.value("ui.modern.search_link_json")!?json_string}?${response.resultPacket.spell.url?json_string}&form=json",
      "text" : "${response.resultPacket.spell.text?json_string}"
     <#else>
      "url" : null,
      "text" : null
     </#if>
     
   }
</#macro>

<#-- Create the json for the selected facet categories and values --> 
<#macro SelectedFacetValues >
   "selectedCategoryValues" : 
   {
      <#list question.selectedCategoryValues?keys as key>
        <#-- Change category value to display the facet's name -->
        <#if key?json_string?contains("Keywords")>"Keywords"<#elseif key?json_string?contains("File Type")>"File Type"<#elseif key?json_string?contains("Content")>"Content"<#elseif key?json_string?contains("Social")>"Social"<#else>"${key?json_string}"</#if> : [    
        <#-- List out the values that have been selected -->
        <#list question.selectedCategoryValues[key] as value>
        <#if value?json_string = "pdf">"${value?json_string?upper_case}"</#if>  
        <#-- Insert comma if there are more items -->
         <#if value_has_next>,</#if>
        </#list>
        ]
        <#-- Insert comma if there are more items -->
         <#if key_has_next>,</#if>
      </#list>
   }
</#macro>

<#-- Create the json for the available facets --> 
<#macro Facets>
   <#if (response.facets)!?has_content> 
      "facet" : 
      [
        <#list response.facets as key>
        { "name" : "${key.name?json_string}"
         ,"unselectAllUrl" : "${question.collection.configuration.value("ui.modern.search_link_json")!?json_string}${key.unselectAllUrl!?json_string}"
         ,"categories" : [
            <#list key.categories as categories>
            { 
                "queryStringParamName" : "${categories.queryStringParamName?json_string}"
                ,"values" : [
                      <#list categories.values as values>
                      {
                          "data" : "${values.data?json_string}"
                          ,"label" : "${values.label?json_string}"
                          ,"count" : "${values.count?json_string}"
                          ,"queryStringParam" : "${values.queryStringParam?json_string}"
                      }
                      <#-- Insert comma if there are more items -->
                      <#if values_has_next>,</#if>
                      </#list>
                   
                  ]
            }
            <#-- Insert comma if there are more items -->
            <#if categories_has_next>,</#if>
            </#list>
          ]
         }
         <#-- Insert comma if there are more items -->
         <#if key_has_next>,</#if>
        </#list>
      ]
   <#else>
      "facet" : 
      [
      {
         "name" : null,
         "categories" : null
      }
      ]
   </#if>
</#macro>

<#-- Create the json for the available curator --> 
<#macro Curator>
      "curator" : 
        {  <#if (response.curator.exhibits)!?has_content> 
            "exhibits" :  [
                    <#list response.curator.exhibits as exhibits>
                            { 
                                "titleHtml:" : "${exhibits.titleHtml!?json_string}",
                                "messageHtml:" : "${exhibits.messageHtml!?json_string}",
                                "displayUrl" : "${exhibits.displayUrl!?json_string}",
                                "linkUrl": "${question.collection.configuration.value("ui.modern.click_link_json")!?json_string}${exhibits.linkUrl!?json_string}",
                                "descriptionHtml": "${exhibits.descriptionHtml!?json_string}",
                                "category": "${exhibits.category!?json_string}"
                            }
                            <#-- Insert comma if there are more items -->
                            <#if exhibits_has_next>,</#if>
                            </#list>
                         ]
            <#else>
            "exhibits" : null
            </#if>           
         }
</#macro>
<#-- Print the JSON -->
<@JSON />

