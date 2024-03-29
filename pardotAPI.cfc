<cfcomponent displayname="PARDOTAPI" output="false">

    <!--- INIT FUNCTION START --->
	<cffunction name="init" access="public" output="false" hint="I am the constructor">
		<cfargument name="email" 		required="true" type="string" />
		<cfargument name="password" 	required="true" type="string" />
		<cfargument name="user_key" 	required="true" type="string" />

		<cfset variables.email 	= arguments.email>
		<cfset variables.password = arguments.password>
		<cfset variables.user_key = arguments.user_key>

        <cfset variables.instance.apiURL = 'https://pi.pardot.com'>
		<cfset variables.APIKEY = getAPIkey()>

		<cfreturn this>
	</cffunction>
	<!--- INIT FUNCTION END --->

    <!--- GET API KEY START--->
	<cffunction name="getAPIkey" access="private" returntype="any">

		<cfhttp url="https://pi.pardot.com/api/login/version/3" method="post" result="result">
		  	<cfhttpparam type="formField" name="email" value="#variables.email#" >
		  	<cfhttpparam type="formField" name="password" value="#variables.password#" >
		  	<cfhttpparam type="formField" name="user_key" value="#variables.user_key#">
		</cfhttp>
        <cfset api_key = mid(result.filecontent,82,32)>
        <cfreturn api_key>
	</cffunction>
    <!--- GET API KEY  END--->

    <!--- GET LATEST LIST  START--->
	<cffunction name="latestList" access="public" returntype="any" >
		
		<cfset res= makeHttpRequest( variables.instance.apiURL&"list/version/3/do/query?output=mobile", "POST",{},{},{} )>
 		<cfreturn res.filecontent>
	</cffunction>
    <!--- GET LATEST LIST  END--->

    <!--- GET PROSPECTS USING EMAIL ADDRESS START(MUST NEED EMAIL ADDRESS)--->
    <cffunction name="getprospects" access="public" returntype="any">
    	<cfargument name="email" type="string" default="">

		<cfset post_parameters = {"email" = arguments.email}>
		<cfset res= makeHttpRequest( variables.instance.apiURL&"prospect/version/3/do/read/?", "POST",post_parameters,{},{} )>
 		<cfreturn res.filecontent>
    </cffunction>
    <!--- GET PROSPECTS USING EMAIL ADDRESS END--->
    
    <!--- UPDATE PROSPECTS(Email List Subscriptions) START(MUST NEED EMAIL AND LIST_ID) --->
    <cffunction name="updateprospects" access="public" returntype="any">
    	<cfargument name="email" type="string" >
		<cfargument name="id" type="numeric" >
		<cfargument name="value" type="numeric" default="1">

		<cfset post_parameters = {"email" = arguments.email}>
		<cfset res= makeHttpRequest( variables.instance.apiURL&"prospect/version/3/do/update/email/#arguments.email#?list_#arguments.id#=#arguments.value#", "POST",post_parameters,{},{} )>
 		<cfreturn res.filecontent>
    </cffunction>
    <!--- UPDATE PROSPECTS END --->
    
    <!--- CREATE PROSPECTS START (MUST NEED MUST BE A UNIQUE EMAIL ADDRESS) --->
    <cffunction name="createprospects" access="public" returntype="any">
    	<cfargument name="email" type="string" >
    	<cfargument name="user_key" type="string">
    	<cfargument name="api_key" type="string">

    	<cfset post_parameters = {"email" = arguments.email}>
		<cfset res= makeHttpRequest( variables.instance.apiURL&"/api/prospect/version/3/do/create/email/#arguments.email#?user_key=#arguments.user_key#&api_key=#api_key#", "POST",post_parameters,{},{} )>
 		<cfreturn res.filecontent>
    </cffunction>
    <!--- CREATE PROSPECTS END --->
    
    <!--- DELETE PROSPECTS USING EMAIL ID START (MUST NEED VALID EMAIL ID)--->
    <cffunction name="deleteprospects" access="public" returntype="any">
    	<cfargument name="email" type="string" >
    	<cfargument name="user_key" type="string">
    	<cfargument name="api_key" type="string">

    	<cfset post_parameters = {"email" = arguments.email}>
		<cfset res= makeHttpRequest( variables.instance.apiURL&"/api/prospect/version/3/do/delete/email/#arguments.email#?user_key=#arguments.user_key#&api_key=#api_key#", "POST",post_parameters,{},{} )>
 		<cfreturn res.filecontent>
    </cffunction>
    <!--- DELETE PROSPECTS USING EMAIL ID END--->

	<!--- MAKE HTTP REQUST START--->
	<cffunction name="makeHttpRequest" access="private" output="false" hint="">
		<cfargument name="url" 			type="string" 	displayname="url" 		hint="URL to request" 		required="true" />
		<cfargument name="method" 		type="string" 	displayname="method" 	hint="Method of HTTP Call" 	required="true" />
		<cfargument name="post_parameters" 	type="struct" 	hint="HTTP parameters" 	required="false" default="#structNew()#" />
		<cfargument name="url_parameters" 	type="struct" 	hint="HTTP parameters" 	required="false" default="#structNew()#" />
		<cfargument name="header_parameters" 	type="struct" 	hint="HTTP parameters" 	required="false" default="#structNew()#" />
       
		<cfhttp url="#arguments.url#" method="#arguments.method#" result="returnStruct"  >

				
			<cfhttpparam type="formfield" name="user_key" value="#variables.user_key#" />
			<cfhttpparam type="formfield" name="api_key" value="#variables.api_key#" />	

			<cfif NOT StructIsEmpty(post_parameters)>
				<cfloop collection="#arguments.post_parameters#" item="local.key">
					<cfhttpparam type="formfield" name="#key#" value="#arguments.post_parameters[key]#" />
				</cfloop>
			</cfif>

			<cfif NOT StructIsEmpty(header_parameters)>
				<cfloop collection="#arguments.header_parameters#" item="local.key">
					<cfhttpparam type="header" name="#key#" value="#arguments.header_parameters[key]#" />
				</cfloop>
			</cfif>
		</cfhttp>
		
		<cfreturn returnStruct>
	</cffunction>
	<!--- MAKE HTTP REQUST END--->

    <!--- XML TO STRUCTURE CONVERSION START --->
	<cffunction name="ConvertXmlToStruct" access="public" returntype="struct" output="false"
				hint="Parse raw XML response body into ColdFusion structs and arrays and return it.">
		<cfargument name="xmlNode" type="string" required="true" />
		<cfargument name="str" type="struct" required="true" />
		<!---Setup local variables for recurse: --->
		<cfset var i = 0 />
		<cfset var axml = arguments.xmlNode />
		<cfset var astr = arguments.str />
		<cfset var n = "" />
		<cfset var tmpContainer = "" />
		
		<cfset axml = XmlSearch(XmlParse(arguments.xmlNode),"/node()")>
		<cfset axml = axml[1] />
		<!--- For each children of context node: --->
		<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
			<!--- Read XML node name without namespace: --->
			<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
			<!--- If key with that name exists within output struct ... --->
			<cfif structKeyExists(astr, n)>
				<!--- ... and is not an array... --->
				<cfif not isArray(astr[n])>
					<!--- ... get this item into temp variable, ... --->
					<cfset tmpContainer = astr[n] />
					<!--- ... setup array for this item beacuse we have multiple items with same name, ... --->
					<cfset astr[n] = arrayNew(1) />
					<!--- ... and reassing temp item as a first element of new array: --->
					<cfset astr[n][1] = tmpContainer />
				<cfelse>
					<!--- Item is already an array: --->
					
				</cfif>
				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
						<!--- recurse call: get complex item: --->
						<cfset astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
					<cfelse>
						<!--- else: assign node value as last element of array: --->
						<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
				</cfif>
			<cfelse>
				<!---
					This is not a struct. This may be first tag with some name.
					This may also be one and only tag with this name.
				--->
				<!---
						If context child node has child nodes (which means it will be complex type): --->
				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<!--- recurse call: get complex item: --->
					<cfset astr[n] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
					<!--- else: assign node value as last element of array: --->
					<!--- if there are any attributes on this element--->
					<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
						<!--- assign the text --->
						<cfset astr[n] = axml.XmlChildren[i].XmlText />
							<!--- check if there are no attributes with xmlns: , we dont want namespaces to be in the response--->
						 <cfset attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
						 <cfloop from="1" to="#listLen(attrib_list)#" index="attrib">
							 <cfif ListgetAt(attrib_list,attrib) CONTAINS "xmlns:">
								 <!--- remove any namespace attributes--->
								<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(attrib_list,attrib))>
							 </cfif>
						 </cfloop>
						 <!--- if there are any atributes left, append them to the response--->
						 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
							 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
						</cfif>
					<cfelse>
						 <cfset astr[n] = axml.XmlChildren[i].XmlText />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<!--- return struct: --->
		<cfreturn astr />
	</cffunction>
    <!--- XML TO STRUCTURE CONVERSION END --->
</cfcomponent>