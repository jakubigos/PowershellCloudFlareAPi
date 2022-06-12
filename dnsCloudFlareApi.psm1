# CloudFlare Powershell API wrapper 
# Author: Jakub Bigos


New-Variable -Name apiUrl -Value 'https://api.cloudflare.com/' -Scope Script -Option ReadOnly -Force
New-Variable -Name contentType -Value 'application/json' -Scope Script -Option ReadOnly -Force


#https://api.cloudflare.com/#dns-records-for-a-zone-create-dns-record
function New-DnsRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateSet("A", "AAAA", "CNAME", "HTTPS", "TXT", "SRV", "LOC", "MX", "NS", "CERT", "DNSKEY", "DS", "NAPTR", "SMIMEA", "SSHFP", "SVCB", "TLSA", "URI")]
        [string] $type,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateLength(1,255)]
        [string] $name,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $content,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateScript({$_ -eq 1 -or ($_ -ge 60 -and $_ -le 86400)})]
        [int] $ttl,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0,65535)]
        [int] $priority,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $proxied,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $zone,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $authKey

    )
    Begin {  
        $method = "POST"
    }
    Process {
        $headers = @{
            'Authorization' = "Bearer $authKey"
            'Content-Type' = $contentType
        }
        $body = @{
            'type' = $type
            'name' = $name
            'content' = $content
            'ttl' = $ttl
        }

        if($PSBoundParameters.ContainsKey('priority')){
            $body.Add('priority', $priority)
        }

        if($PSBoundParameters.ContainsKey('proxied')){
            $body.Add('proxied', $proxied)
        }

        $url = $apiUrl + "client/v4/zones/$zone/dns_records"

        Write-Host "Creating new DNS record: $name ($content)"
        $result = Invoke-RestMethod -Uri $url -Method $method -Headers $headers -Body ($body|ConvertTo-Json) -ContentType $contentType
        if ($result.result -eq 'error'){
            throw $($result.msg)
        }
    }
    End {
        $result.result
    }    
}

#https://api.cloudflare.com/#dns-records-for-a-zone-dns-record-details
function Get-DnsRecord {
    param(
       [Parameter(Mandatory=$true)]
       [string] $identifier,

       [Parameter(Mandatory=$true)]
       [string] $zone,

       [Parameter(Mandatory=$true)]
       [string] $authKey

    )
    Begin {
        $method = "GET"

    }
    Process {
        $headers = @{
            'Authorization' = "Bearer $authKey"
            'Content-Type' = $contentType
        }

        $url = $apiUrl + "client/v4/zones/$zone/dns_records/$identifier"

        $result = Invoke-RestMethod -Uri $url -Method $method -Headers $headers -ContentType $contentType
        if ($result.result -eq 'error'){
            throw $($result.msg)
        }
    }
    End {
        $result.result
    }   
}

#https://api.cloudflare.com/#dns-records-for-a-zone-list-dns-records
function Get-DnsRecords {
    param(
        [ValidateSet("A", "AAAA", "CNAME", "HTTPS", "TXT", "SRV", "LOC", "MX", "NS", "CERT", "DNSKEY", "DS", "NAPTR", "SMIMEA", "SSHFP", "SVCB", "TLSA", "URI")]
        [string] $type = "A",

        [ValidateSet("any", "all")]
        [string] $match = "all",

        [ValidateLength(1,255)]
        [string] $name,

        [ValidateSet("type", "name", "content", "ttl", "proxied")]
        [string] $order,

        [ValidateScript({$_ -ge 1})]
        [int] $page = 1,

        [ValidateScript({$_ -ge 5 -and $_ -le 5000})]
        [int] $per_page = 100,

        [string] $content,

        [bool] $proxied,

        [ValidateSet("asc", "desc")]
        [string] $direction = "asc",

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $zone,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $authKey

    )
    Begin {
        $method = "GET"

    }
    Process {  
        $headers = @{
            'Authorization' = "Bearer $authKey"
            'Content-Type' = $contentType
        }
        $urlParameters = @{
            'type' = $type
            'match' = $match   
            'page' = $page
            'per_page' = $per_page
            'direction' = $direction
        }
        if($PSBoundParameters.ContainsKey('name')){
            $urlParameters.Add('name', $name)
        }
        if($PSBoundParameters.ContainsKey('order')){
            $urlParameters.Add('order', $order)
        }
        if($PSBoundParameters.ContainsKey('content')){
            $urlParameters.Add('content', $content)
        }        
        if($PSBoundParameters.ContainsKey('proxied')){
            $urlParameters.Add('proxied', $proxied)
        }  
        
        $url = $apiUrl + "client/v4/zones/$zone/dns_records/?$($urlParameters | Convert-HashToHttpParams)"

        $result = Invoke-RestMethod -Uri $url -Method $method -Headers $headers -ContentType $contentType
        if ($result.result -eq 'error'){
            throw $($result.msg)
        }
    }
    End {
        $result.result
    }   
}

#https://api.cloudflare.com/#dns-records-for-a-zone-update-dns-record
function Update-DnsRecord {
    param (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateSet("A", "AAAA", "CNAME", "HTTPS", "TXT", "SRV", "LOC", "MX", "NS", "CERT", "DNSKEY", "DS", "NAPTR", "SMIMEA", "SSHFP", "SVCB", "TLSA", "URI")]
        [string] $type,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateLength(1,255)]
        [string] $name,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $content,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateScript({$_ -eq 1 -or ($_ -ge 60 -and $_ -le 86400)})]
        [int] $ttl,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $proxied,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $zone,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $authKey,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $identifier
    )
    Begin {
        $method = "PUT"

    }
    Process {
        $headers = @{
            'Authorization' = "Bearer $authKey"
            'Content-Type' = $contentType
        }
        $body = @{
            'type' = $type
            'name' = $name
            'content' = $content
            'ttl' = $ttl
        }

        if($PSBoundParameters.ContainsKey('proxied')){
            $body.Add('proxied', $proxied)
        }

        $url = $apiUrl + "client/v4/zones/$zone/dns_records/$identifier"

        Write-Host "Updating DNS record: $name ($content)"
        $result = Invoke-RestMethod -Uri $url -Method $method -Headers $headers -Body ($body|ConvertTo-Json) -ContentType $contentType
        if ($result.result -eq 'error'){
            throw $($result.msg)
        }
    }
    End {
        $result.result
    }    
}

# creates new DNS record if one doesn't exist
# updates DNS record if it already exists
#
function Set-DnsRecord {
    param (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateSet("A", "AAAA", "CNAME", "HTTPS", "TXT", "SRV", "LOC", "MX", "NS", "CERT", "DNSKEY", "DS", "NAPTR", "SMIMEA", "SSHFP", "SVCB", "TLSA", "URI")]
        [string] $type,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateLength(1,255)]
        [string] $name,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $content,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateScript({$_ -eq 1 -or ($_ -ge 60 -and $_ -le 86400)})]
        [int] $ttl,

        [Parameter(ValueFromPipelineByPropertyName)]        
        [bool] $proxied = $false,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $zone,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [string] $authKey
    )
    Process {
        $parameters = [PSCustomObject]@{
            'type' = $type
            'name' = $name
            'content' = $content
            'ttl' = $ttl
            'zone' = $zone
            'authKey' = $authKey
            'proxied' = $proxied
        }

        $recordDetails = Get-DnsRecords -type $type -name $name -zone $zone -authKey $authKey

        if(($recordDetails.Count) -gt 1){
            throw "More than 1 element having the same record name. You need to use Update-DnsRecord with precise record identifier instead."
        }
        elseif(($recordDetails.Count) -eq 0){
            $parameters | New-DnsRecord
        }
        elseif(($recordDetails.Count) -eq 1){
            $parameters | Add-Member -NotePropertyMembers @{identifier=($recordDetails.id)} -PassThru
            $parameters | Update-DnsRecord           
        }
    }
}

#Generates string of URL paramters for GET requests based on hash table 
# based on https://stackoverflow.com/a/32453207
function Convert-HashToHttpParams {
    param (
        [Parameter(ValueFromPipeline)]
        $hashTable
    )

    $HttpValueCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    foreach ($Item in $hashTable.GetEnumerator()) {      
            $HttpValueCollection.Add($Item.Key,$Item.Value)       
    }

    return $($HttpValueCollection.toString())
}