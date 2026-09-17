# Domain Mapping Table (Devhub -> API Portal)

Use this file as the canonical source for resolving and validating `locations[].domain` in `apis/api-portal.yml`.

## Mandatory Mapping Table

```yaml
analytics:
   - analytics
   - analyticscommerce
   - tempebi

apps:
   - appsecom
   - boecommerce
   - commobile
   - ecommercelegacy
   - frontend
   - sitemngmnt
   - webecom
   - storeit
   - corptools
   - wcsecom
   - zzold

brick-and-mortar:
   - brickmortar
   - psops
   - pspos

commercial:
   - comanalysis
   - commerman
   - combi
   - comcore
   - commaster
   - tempecommerc
   - oyshotwu

communication:
   - communication
   - corpcomu
   - crmcallcenter

customers:
   - customer

customs:
   - customs

data:
   - databigdata
   - datacloud
   - dataecom
   - dataops
   - dataperf
   - dbcontrol
   - dgoffice
   - dgquality
   - infoadqui
   - infoexpo
   - inforepos
   - inforings
   - mlearn
   - opresearch

distribution:
   - sedistrib
   - comdistrib

facilities:
   - inframgmt
   - tempecorp

factories:
   - factorymg
   - tempeprod

finance:
   - accounting
   - conciliation
   - controlmgmt
   - finance
   - fininvoicing
   - finmasters
   - finreporting
   - fiscal
   - invoicing
   - procurement
   - treasury

fraud:
   - fraud

hrhr:
   - healthsafe
   - hranlytics
   - hrmestros
   - hroptcont
   - hrorganiza
   - hrpayroll
   - hrpersadm
   - hrrecruit
   - hrtraining
   - hrutils
   - hrcompensa
   - hremployee
   - hrevalua
   - travelmgmt

internationalization:
   - intrnational

legal-and-compliance:
   - compliance
   - legal
   - complclass

logistics:
   - psrelabel
   - returns
   - movements
   - corestock
   - psmultich
   - psrfid
   - tempelog
   - adminmaster

marketing:
   - marketing
   - promotion

marketplaces:
   - mrktplcs

orders:
   - orders

payments:
   - payment

product-and-catalog:
   - content
   - productandcatalog
   - tempedesign

purchase:
   - purchase
   - tempepurch

real-state:
   - construction

risk-management:
   - auditrisk
   - governance
   - pcandrm

security:
   - analyzers
   - access
   - detection
   - endpoint
   - identity
   - knowledge
   - orchestra
   - physicalsec
   - swsecurity

stock:
   - stockbi
   - stock
   - stockassesm
   - stockmgmt
   - whstockmng

supply-chain:
   - ppi
   - compsupchain
   - fulfilment
   - tempecore

sustainability:
   - energycoeff
   - eva
   - phs
   - scc

technology:
   - psdevman
   - core
   - inftools
   - iopstools
   - managetool
   - officeit
   - rpa
   - swapi
   - swdelivery
   - swdevelop
   - swobservb
   - swobservapm
   - swoperation
   - swquality
   - asquatro

transports:
   - trcommons
   - exportr
   - importr
   - localtr
   - traceabi
   - transport

warehouses:
   - sgadelivery
   - sgaepacking
   - sgaeshipping
   - sgapacking
   - sgashipping
   - sgafrmk
   - sgaobserva
   - sgaoptech
   - sgasimula
   - sgawkshp
   - sgauserxp
   - sgarfid
   - sgagilo
   - sgabuffering
   - sgainbound
   - sgalabelling
   - sgaoptimiza
   - sgarobotics
   - sgasortation
   - sgastorager
   - sgawarehms
```

## Allowed Values for `locations[].domain`

`analytics`, `apps`, `brick-and-mortar`, `commercial`, `communication`, `customers`, `customs`, `data`, `distribution`, `facilities`, `factories`, `finance`, `fraud`, `hrhr`, `internationalization`, `legal-and-compliance`, `logistics`, `marketing`, `marketplaces`, `orders`, `payments`, `product-and-catalog`, `purchase`, `real-state`, `risk-management`, `security`, `stock`, `supply-chain`, `sustainability`, `tbd`, `technology`, `transports`, `warehouses`.
