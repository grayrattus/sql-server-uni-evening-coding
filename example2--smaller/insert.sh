#/bin/bash

join -a 1 -e EMPTY -1 12 -2 1 -t';' <(sort -k 12 -t';' orders.csv) <(sort -k 1 -t';' products.csv) > merger_orders_products.csv
join --nocheck-order -a 1 -e EMPTY -1 10 -2 2 -t';' <(sort -u -k10 -t';' merger_orders_products.csv) <(sort -k 2 -t';' geography.csv) > merger_orders_products_geography.csv

while IFS= read -r order; do
  City=$(echo $order | cut -d ';' -f 1 | sed "s/'//g" ) ;
  ProductID=$(echo $order | cut -d ';' -f 2 | sed "s/'//g" ) ;
  OrderID=$(echo $order | cut -d ';' -f 3 | sed "s/'//g" ) ;
  OrderDate=$(echo $order | cut -d ';' -f 4 | sed "s/'//g" ) ;
  ShipDate=$(echo $order | cut -d ';' -f 5| sed "s/'//g"  ) ;
  ShipMode=$(echo $order | cut -d ';' -f 6 | sed "s/'//g" ) ;
  CustomerID=$(echo $order | cut -d ';' -f 7 | sed "s/'//g" ) ;
  CustomerName=$(echo $order | cut -d ';' -f 8 | sed "s/'//g" ) ;
  Segment=$(echo $order | cut -d ';' -f 9 | sed "s/'//g"  ) ;
  PostalCode=$(echo $order | cut -d ';' -f 10 | sed "s/'//g" ) ;
  State=$(echo $order | cut -d ';' -f 11 | sed "s/'//g"  ) ;
  Country=$(echo $order | cut -d ';' -f 12 | sed "s/'//g" ) ;
  Sales=$(echo $order | cut -d ';' -f 13 | sed "s/'//g"  ) ;
  Quantity=$(echo $order | cut -d ';' -f 14 | sed "s/'//g" ) ;
  Discount=$(echo $order | cut -d ';' -f 15 | sed "s/'//g" ) ;
  Profit=$(echo $order | cut -d ';' -f 16 | sed "s/'//g" ) ;
  ShippingCost=$(echo $order | cut -d ';' -f 17 | sed "s/'//g" ) ;
  Category=$(echo $order | cut -d ';' -f 18 | sed "s/'//g" ) ;
  SubCategory=$(echo $order | cut -d ';' -f 19 | sed "s/'//g" ) ;
  ProductName=$(echo $order | cut -d ';' -f 20 | sed "s/'//g"  )

  echo "EXEC dziedziczak.firma.dodaj_kategorie '$Category', '$SubCategory', '$ProductName', '$ProductID', '$Country', '$Market', '$State', '$City', '$CustomerName', '$CustomerID', '$Segment', '$ShipMode', '$OrderID', '$OrderDate', '$ShipDate', '$postalCode', '$Sales', 0, $Discount, '$Profit', $ShippingCost"
  echo GO
done < merger_orders_products_geography.csv
