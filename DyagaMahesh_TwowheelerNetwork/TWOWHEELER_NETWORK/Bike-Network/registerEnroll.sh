#!/bin/bash

function createBikeManufacturer() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/bikemanufacturer.auto.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-bikemanufacturer --tls.certfiles "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-bikemanufacturer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-bikemanufacturer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-bikemanufacturer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-bikemanufacturer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy bikemanufacturer's CA cert to bikemanufacturer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/msp/tlscacerts/ca.crt"

  # Copy bikemanufacturer's CA cert to bikemanufacturer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/tlsca/tlsca.bikemanufacturer.auto.com-cert.pem"

  # Copy bikemanufacturer's CA cert to bikemanufacturer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/ca"
  cp "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/ca/ca.bikemanufacturer.auto.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-bikemanufacturer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-bikemanufacturer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-bikemanufacturer --id.name bikemanufactureradmin --id.secret bikemanufactureradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-bikemanufacturer -M "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/peers/peer0.bikemanufacturer.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/peers/peer0.bikemanufacturer.auto.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-bikemanufacturer -M "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/peers/peer0.bikemanufacturer.auto.com/tls" --enrollment.profile tls --csr.hosts peer0.bikemanufacturer.auto.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/peers/peer0.bikemanufacturer.auto.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/peers/peer0.bikemanufacturer.auto.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/peers/peer0.bikemanufacturer.auto.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/peers/peer0.bikemanufacturer.auto.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/peers/peer0.bikemanufacturer.auto.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/peers/peer0.bikemanufacturer.auto.com/tls/server.key"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-bikemanufacturer -M "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/users/User1@bikemanufacturer.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/users/User1@bikemanufacturer.auto.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://bikemanufactureradmin:bikemanufactureradminpw@localhost:7054 --caname ca-bikemanufacturer -M "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/users/Admin@bikemanufacturer.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bikemanufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bikemanufacturer.auto.com/users/Admin@bikemanufacturer.auto.com/msp/config.yaml"
}

function createBikeDealer() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/bikedealer.auto.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/bikedealer.auto.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-bikedealer --tls.certfiles "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bikedealer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bikedealer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bikedealer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bikedealer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy bikedealer's CA cert to bikedealer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/msp/tlscacerts/ca.crt"

  # Copy bikedealer's CA cert to bikedealer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/tlsca/tlsca.bikedealer.auto.com-cert.pem"

  # Copy bikedealer's CA cert to bikedealer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/ca"
  cp "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/ca/ca.bikedealer.auto.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-bikedealer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-bikedealer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-bikedealer --id.name bikedealeradmin --id.secret bikedealeradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-bikedealer -M "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/peers/peer0.bikedealer.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/peers/peer0.bikedealer.auto.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-bikedealer -M "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/peers/peer0.bikedealer.auto.com/tls" --enrollment.profile tls --csr.hosts peer0.bikedealer.auto.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/peers/peer0.bikedealer.auto.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/peers/peer0.bikedealer.auto.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/peers/peer0.bikedealer.auto.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/peers/peer0.bikedealer.auto.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/peers/peer0.bikedealer.auto.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/peers/peer0.bikedealer.auto.com/tls/server.key"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-bikedealer -M "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/users/User1@bikedealer.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/users/User1@bikedealer.auto.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://bikedealeradmin:bikedealeradminpw@localhost:8054 --caname ca-bikedealer -M "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/users/Admin@bikedealer.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bikedealer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bikedealer.auto.com/users/Admin@bikedealer.auto.com/msp/config.yaml"
}


function createMvd() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/mvd.auto.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/mvd.auto.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-mvd --tls.certfiles "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-mvd.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-mvd.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-mvd.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-mvd.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/mvd.auto.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy mvd's CA cert to mvd's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/mvd.auto.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem" "${PWD}/organizations/peerOrganizations/mvd.auto.com/msp/tlscacerts/ca.crt"

  # Copy mvd's CA cert to mvd's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/mvd.auto.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem" "${PWD}/organizations/peerOrganizations/mvd.auto.com/tlsca/tlsca.mvd.auto.com-cert.pem"

  # Copy mvd's CA cert to mvd's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/mvd.auto.com/ca"
  cp "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem" "${PWD}/organizations/peerOrganizations/mvd.auto.com/ca/ca.mvd.auto.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-mvd --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-mvd --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-mvd --id.name mvdadmin --id.secret mvdadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-mvd -M "${PWD}/organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mvd.auto.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-mvd -M "${PWD}/organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls" --enrollment.profile tls --csr.hosts peer0.mvd.auto.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/mvd.auto.com/peers/peer0.mvd.auto.com/tls/server.key"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-mvd -M "${PWD}/organizations/peerOrganizations/mvd.auto.com/users/User1@mvd.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mvd.auto.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mvd.auto.com/users/User1@mvd.auto.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://mvdadmin:mvdadminpw@localhost:11054 --caname ca-mvd -M "${PWD}/organizations/peerOrganizations/mvd.auto.com/users/Admin@mvd.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mvd/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mvd.auto.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mvd.auto.com/users/Admin@mvd.auto.com/msp/config.yaml"
}


function createOrderer() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/auto.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/auto.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/auto.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/auto.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/auto.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/auto.com/tlsca/tlsca.auto.com-cert.pem"

  echo "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/auto.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/msp/config.yaml"

  echo "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls" --enrollment.profile tls --csr.hosts orderer.auto.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/auto.com/orderers/orderer.auto.com/msp/tlscacerts/tlsca.auto.com-cert.pem"

  echo "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/auto.com/users/Admin@auto.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/auto.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/auto.com/users/Admin@auto.com/msp/config.yaml"
}

createBikeManufacturer
createBikeDealer
createMvd
createOrderer
