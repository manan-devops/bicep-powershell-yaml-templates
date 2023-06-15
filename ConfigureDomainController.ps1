# Powershell DSC script that configures Domain Controller 
Configuration ConfigureCloudAD
{

param
    (

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AdminCreds,

       [Parameter(Mandatory)]
       [System.Management.Automation.PSCredential]$SafeModeCreds,

        [Parameter(Mandatory)]
        [String]$DomainName,
		
		[Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30

    )

Import-DscResource -ModuleName  ComputerManagementDsc, ActiveDirectoryDsc, xDnsServer, NetworkingDsc, DFSDsc, WmiNamespaceSecurity, StorageDSC

	node localhost
	{

        	LocalConfigurationManager
        	{
            	RebootNodeIfNeeded = $true
        	}
		
		Computer Rename
		{
	    	Name = 'TINFAD01'
		}
		
        	WaitforDisk Disk2
        	{	
            	DiskId = 2
            	RetryIntervalSec =$RetryIntervalSec
            	RetryCount = $RetryCount
       	 	}

        	Disk ADPrograms 
		{
            	DiskId = 2
            	DriveLetter = "F"
		FSFormat = "NTFS"
            	DependsOn = "[WaitForDisk]Disk2"
        	}
		
		File ADNTDSFiles
		{
		  DestinationPath 		= 'F:\AD\NTDS'
		  Type 				= 'Directory'
		  Ensure 			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		File ADSYSVOLFiles
		{
		  DestinationPath 		= 'F:\AD\SYSVOL'
		  Type 				= 'Directory'
		  Ensure 			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		File ADLogFiles
		{
		  DestinationPath 		= 'F:\AD\Logs'
		  Type 				= 'Directory'
		  Ensure 			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		#######################################
		###########  Windows Features #########
		#######################################

		WindowsFeature 'ADDomainServices'
		{
		  Name				= "AD-Domain-Services"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'DNS'
		{
		  Name				= "DNS"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'FSFileServer'
		{
		  Name				= "FS-FileServer"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'FSDFSNamespace'
		{
		  Name				= "FS-DFS-Namespace"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'FSDFSReplication'
		{
		  Name				= "FS-DFS-Replication"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'NetFramework45Core'
		{
		  Name				= "NET-Framework-45-Core"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'NetWCFTCPPortSharing45'
		{
		  Name				= "NET-WCF-TCP-PortSharing45"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'GPMC'
		{
		  Name				= "GPMC"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}	


		WindowsFeature 'RSATADPowerShell'
		{
		  Name				= "RSAT-AD-PowerShell"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}
		
       		WindowsFeature 'ADDSInstall'
        	{
            	Ensure = "Present"
            	Name = "AD-Domain-Services"
        	}
		
		WindowsFeature 'RSATADDS'
		{
		  Name				= "RSAT-ADDS"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

        	WindowsFeature 'ADDSTools'
        	{
            	Ensure = "Present"
            	Name = "RSAT-ADDS-Tools"
            	DependsOn = "[WindowsFeature]ADDSInstall"
        	}	

		WindowsFeature 'RSATADTools'
		{
		  Name				= "RSAT-AD-Tools"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'RSATDNSServer'
		{
		  Name				= "RSAT-DNS-Server"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'RSATDFSMgmtCon'
		{
		  Name				= "RSAT-DFS-Mgmt-Con"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'TelnetClient'
		{
		  Name				= "Telnet-Client"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'WindowsDefender'
		{
		  Name				= "Windows-Defender"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'WindowsDefenderGui'
		{
		  Name				= "Windows-Defender-Gui"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		WindowsFeature 'WOW64Support'
		{
		  Name				= "WoW64-Support"
		  Ensure			= 'Present'
		  DependsOn			= '[Computer]Rename'
		}

		PendingReboot AfterFeature
		{
		  Name				="After Feature Install"
		}

		#######################################
		########### Domain Setup ##############
		#######################################

		WaitForADDomain DscForestWait
        	{
            	  DomainName 			= $DomainName
            	  Credential 			= $AdminCreds
            	  #RetryCount 			= 50
            	  #RetryIntervalSec 		= 30
            	  DependsOn 			= "[WindowsFeature]ADDomainServices"
        	}
		
		ADDomainController CloudDC
        	{
            	  DomainName 			= $DomainName
            	  Credential 			= $AdminCreds
            	  SafemodeAdministratorPassword = $AdminCreds
            	  #DnsDelegationCredential 	= $DNSDelegationCred
		  DatabasePath 			= 'F:\AD\NTDS'
		  LogPath 			= 'F:\AD\Logs'
		  SysvolPath			= 'F:\AD\SYSVOL'
            	  DependsOn 			= "[WaitForADDomain]DscForestWait"
        	}

		PendingReboot AfterDCPromotion
		{
		  Name				="After DC Promotion"
		}

		#######################################
		###########  DNS Server Settings ######
		#######################################

		xDnsServerSetting LocalnetPriority
		{
			Name			= 'SetLocalNetPriorityto1'
			RoundRobin		= $true
		}

		xDnsServerSetting enableRoundRobin
		{
			Name			= 'EnableRoundRobin'
			RoundRobin		= $true
		}
 
		
		#######################################
		###########  DNS Zones   ##############
		#######################################
		
		xDnsServerADZone AddRDNS-CloudFrontEnd
    		{
        	  Name 					= '1.193.10.in-addr.arpa'
        	  DynamicUpdate 			= 'Secure'
        	  ReplicationScope 			= 'Forest'
        	  Ensure 				= 'Present'
		  DependsOn				= '[ADDomainController]CloudDC'
    		}


		#######################################
		###########  DNS Records ##############
		#######################################

		xDnsRecord time03
		{
		  Ensure				= 'Present'
		  Name					= 'time03'
		  Zone					= '-one.local'
		  Target				= 'time.windows.com'
		  Type					= 'CName'
		  DependsOn				= '[ADDomainController]CloudDC'
		}

		#######################################
		########### Cloud Servers #############
		#######################################
	
		ADComputer TSQLDB01
		{
		  ComputerName				= 'TSQLDB01'
		  DnsHostName				= 'TSQLDB01.test-One.local'
		  Path					= 'OU=CAD,OU=testOne Servers,DC=test-One,DC=local'
		  Description				= 'TSQL DB Server 01'
		  EnabledOnCreation 			= $false
		  DependsOn				= '[ADDomainController]CloudDC'
		}


	}
}
