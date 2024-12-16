## Steps to create minifab network

- In the project directory we create a spec.yaml file.
  
   - In spec.yaml file we will write how many CA's we want, peers and Orderers.

- To run that spec.yaml file we have to execute the following commands.
   
    <code>minifab netup -s couchdb -e true -i 2.4.8 -o PoliceDepartment.vehicleinsurance.com </code> 

- Above command is used to initializing or configuring a Hyperledger Fabric network

- Below command is used to create channel

     <code>minifab create -c autochannel</code>

-  Next we have to join in the minifab network for that we use the following command

      <code>minifab join -c autochannel</code>

- The command is used to modify the channel configuration so that the new or updated anchor peers are properly registered and visible to other organizations.

       <code>minifab anchorupdate</code>

- The Command we use to create profile is

       <code>minifab profilegen</code>

### Steps to create script file

- We create this script file in minifab network project directory insteading of using all the above commands.

- We use below two commands after writing script file to create minifab network.

       <code>chmod +x startNetwork.sh</code>

       <code>./startNetwork.sh</code>

- To cleanup the minifab use the following command

       <code>minifab cleanup</code>

## Steps to create ChainCode for Insurance UseCase   

- To create chaincode first we need to initializing a go project with module name by using following command
 
  <code>go mod init insurance</code>

- I given module name as insurance.

- Next step is we need to import the required packages for the hyperledgerfabric chaincode

  <code>go get github.com/hyperledger/fabric-contract-api-go@v1.2.1</code>

- Creating main.go file is the next step
- Now we can start writing the chaincode for <code>vehicle-accident.go</code> by using various functions like

      1.ReportExists:- This functions returns if ReportExists returns true when asset with given Id exists in world state.
      2.CreateAccidentReport:- This function creates new instance of report,by using this we can invoke the reports with details which we pass as arguments in this function.
      3.ReadAccidentReport:-By using this function we can retrieve the data from the world state.
      4.DeleteAccidentReport:-We can delete the data from the world state.

- After writing above functions we can deploy the chaincode.
- First we need to start the network for that we use command <code>./startnetwork.sh</code>
- Next we copy the code by using following commands

  <code>sudo chmod -R 777 vars/</code> This is used to modify any files or directories.

  <code>mkdir -p vars/chaincode/Assignment3/go</code>  If any of the directories in the path don't exist, will create them automatically without raising an error.

  <code>cp -r ../Chaincode/* vars/chaincode/Assignment3/go/</code>  It copies all files and directories from chaincode into the go/ directory.

  <code>minifab ccup -n Assignment3 -l go -v 1.0 -d false -r false</code>  This is typically run when you have made improvements or changes to the chaincode, and you want to deploy the updated version to the network.

  <code>minifab invoke -n Assignment3 -p '"CreateAccidentReport","30/10/2024","Andhrapradesh","Gopi","Report02","AP5432"' -o policedepartment.vehicleinsurance.com</code>  It allows us to invoke transactions in chaincode.

  <code>minifab query -n Assignment3 -p '"ReadAccidentReport","Report01"'</code> Used to get data from the world state.

- In <code>policy-contract.go</code> we create private data functions. The functions we used in this code is 

      1.PolicyExists:- This returns true when asset with given policyId is exists in world state.
      2.CreateInsurancePolicy:- create new instance for POlicy.
      3.ReadInsurancePolicy:- By using this function we can read the data from the world state.
      4.DeleteInsurancePolicy:- We can delete the data by using this function.

- After completing to write the above Private data functions we need to create <code>collection--minifab.json</code> file.

- In a Hyperledger Fabric network, when you want to create a private data collection, you need to define it in a JSON      configuration file. The <code>collection-minifab.json</code> file is used by Minifab to facilitate the creation of these collections when deploying or managing chaincodes.

- The file contains collectionName,policy,requiredPeerCount,maxPeerCount,blockToLive,memberOnlyRead.

- After completing above steps we need to execute the following commands.

       
     <code>cp -r ../chaincode/* vars/chaincode/Assignment3/go/</code>

     <code>cp vars/chaincode/Assignment3/go/collection-minifab.json ./vars/Assignment3_collection_config.json</code>

     <code>minifab ccup -n Assignment3 -l go -v 1.0 -d false -r true</code>

       PolicyHolder=$(echo -n "Rahul" | base64 | tr -d \\n)
       PolicyAmount=$(echo -n "150000" | base64 | tr -d \\n)
       PolicyType=$(echo -n "BikeInsurance" | base64 | tr -d \\n)

     <code>minifab invoke -n Assignment3 -p '"PolicyContract:CreateInsurancePolicy","Policy01"' -t '{"policyHolder":"'$PolicyHolder'","policyAmount":"'$PolicyAmount'","policyType":"'$PolicyType'"}' -o insurancecompany.vehicleinsurance.com</code>

- For reading the Insurance policy we need the following command.

      <code>minifab query -n Assignment3 -p '"PolicyContract:ReadInsurancePolicy","policy01"'</code>     

- In <code>vehicle-accident.go</code> file we implement some more functions like as follows

      1.GetAllReports:-To get all reports data which are in worldstate or blockchain
      2.GetReportsByRange:- This function used to get reports by range that means which index to which index we want.
      3.GetReportHistory
      4.GetReportsWithPagination

- we execute the following commands to implement above functions

    -Execute the following command in chaincode folder to install the additional shim package

   <code>go mod tidy</code>

- Deploy the chaincode again to use richqueries and execute these in minifab folder  

   <code>cp -r ../chaincode/* vars/chaincode/Assignment3/go/</code> 

   <code>minifab ccup -n KBA-Automobile -l go -v 2.0 -d false -r true</code>

- Next we create some more reports to execute richqueries

       minifab invoke -n Assignment3 -p '"CreateAccidentReport","30/10/2024","Andhrapradesh","Gopi","Report02","AP5432"' -o policedepartment.vehicleinsurance.com

       minifab invoke -n Assignment3 -p '"CreateAccidentReport","30/09/2024","Telangana","Pradeep","Report03","TG5432"'

       minifab invoke -n Assignment3 -p '"CreateAccidentReport","25/10/2024","Andhrapradesh","hanvi","Report04","AP5552"'

       minifab invoke -n Assignment3 -p '"CreateAccidentReport","01/10/2024","Kerala","naina","Report05","KA9999"'

- After invoking some more reports we execute the below command to get all reports to satisfy GetAllReports function.

   <code>minifab query -n Assignment3 -p '"GetAllReports"'</code>

- To sort the Reports we execute the below command in chaincode folder

   <code>mkdir -p META-INF/statedb/couchdb/indexes</code>

- By using above command it creates folder with the name <code>META_INF</code>
- In that we create one file with the name <code>indexReport.json</code> In that we give one field .Based on that field it sort the reports in ascending order.
- Writing the above file again we deploy the code.

- To get the reports by Range we execute the below command
    
   <code>minifab query -n Assignment3 -p '"GetReportsByRange","Report01","Report03"'</code>

- To get history about data we execute the below command

   <code>minifab query -n Assignment3 -p '"GetReportHistory","Report01"'</code>

- To execute pagination query below command is used

   <code>  minifab query -n Assignment3 -p '"GetReportsWithPagination","3",""'</code>

- Now we use rich queries in private data functions

- For that we create two functions in <code>policy-contract.go</code> file
- In that file we implement two functions named as GetAllPolicies and GetPoliciesByRange.

- In that <code>policy-contract.go</code> we invoke some more details
       
      PolicyHolder=$(echo -n "Reshma" | base64 | tr -d \\n)
      PolicyAmount=$(echo -n "100000" | base64 | tr -d \\n)
      PolicyType=$(echo -n "BikeInsurance" | base64 | tr -d \\n)

   <code>minifab invoke -n Assignment3 -p '"PolicyContract:CreateInsurancePolicy","Policy02"' -t '{"policyHolder":"'$PolicyHolder'","policyAmount":"'$PolicyAmount'","policyType":"'$PolicyType'"}' -o insurancecompany.vehicleinsurance.com dealer.auto.com</code>

      PolicyHolder=$(echo -n "Thanish" | base64 | tr -d \\n)
      PolicyAmount=$(echo -n "50000" | base64 | tr -d \\n)
      PolicyType=$(echo -n "BikeInsurance" | base64 | tr -d \\n)

   <code>minifab invoke -n Assignment3 -p '"PolicyContract:CreateInsurancePolicy","Policy03"' -t '{"policyHolder":"'$PolicyHolder'","policyAmount":"'$PolicyAmount'","policyType":"'$PolicyType'"}' -o insurancecompany.vehicleinsurance.com</code>

- To GetAllPolicies in private data function we use the below command

   <code>minifab query -n Assignment3 -p '"PolicyContract:GetAllPolicies"'</code>

- To get policies by range in private data function we use below command
       
   <code>minifab query -n Assignment3 -p '"PolicyContract:GetPoliciesByRange","Policy01","Policy03"'</code>

In this way we implement the chaincode for insurance usecase and deploying chaincode, Private data functions also created and executed by the above process.     


  
          
                     