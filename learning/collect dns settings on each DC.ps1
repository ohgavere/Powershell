(Get-ADForest).Domains | ForEach-Object {

	Get-ADDomainController -Filter * -Server $_ | ForEach-Object {

		Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=TRUE' -ComputerName $_ |

		Format-Table PSComputerName,DnsServerSearchOrder -Wrap -AutoSize |

		Out-File .\DC_DNS_Settings.txt -Append

	}
}