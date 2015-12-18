
$json = @"
{
"Stuffs": 
    [
        {
            "Name": "Darts",
            "Type": "Fun Stuff"
        },

        {
            "Name": "Clean Toilet",
            "Type": "Boring Stuff"
        }
    ]
}
"@ ;

$x = $json | ConvertFrom-Json

# access to Clean Toilet
Write-host $x.Stuffs[1].Name;
Write-host $x.Stuffs[1].Type;

Write-Host "`n===============`n"

$json = @"
{ "users": {
	"Departments": [
		"admin",
		"sales",
		"prod"
	],
	"admin": [
		"user100",
		"user101",
		"user102",
		"user103",
		"user104",
		"user105",
		"user106",
		"user107",
		"user108",
		"user109"
	],
	"sales": [
		"user110",
		"user111",
		"user112",
		"user113",
		"user114",
		"user115",
		"user116",
		"user117",
		"user118",
		"user119"
	],
	"prod": [
		"user120",
		"user121",
		"user122",
		"user123",
		"user124",
		"user125",
		"user126",
		"user127",
		"user128",
		"user129"
	]
  }
}
"@ ;


$x = $json | ConvertFrom-Json

# access to Clean Toilet
$x.Users | ft -Wrap -ShowError -DisplayError | Write-Output;
Write-host $x.Users.admin[1];

Write-Host "`n===============`n"

