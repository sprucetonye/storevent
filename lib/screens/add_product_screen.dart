import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
//import 'package:onielsstore/models/product_list_screen.dart';
import 'package:onielsstore/models/product_model.dart';
import 'package:path_provider/path_provider.dart';



class AddProductScreen extends StatefulWidget {
  final Product? existingProduct;
  
  const AddProductScreen({super.key, this.existingProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _quantityController = TextEditingController();
    final _priceController = TextEditingController();
    String? _imagePath;
  @override

   void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      _nameController.text = widget.existingProduct!.name;
      _quantityController.text = widget.existingProduct!.quantity.toString();
      _priceController.text = widget.existingProduct!.price.toString();
      _imagePath = widget.existingProduct!.imagePath;
    }
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingProduct != null ? "Edit Product" : "Add Product"),
      ),
      body: Padding(padding: 
      EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name'
              ),
              validator: (value) {
                if (value == null || value.isEmpty){
                  return "Please enter a product name";
                }
                return null;
              },
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: "Quantity"
              ),
              keyboardType: TextInputType.number,
              validator: (value){
                if (value == null || value.isEmpty){
                  return "Please enter a quantity";
                }
                if(int.parse(value) < 0){
                  return "Quantity cannot be negative";
                }
                return null;
              },
        
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Price"
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if(value == null || value.isEmpty){
        return "Please enter a price";
                }
                if (double.parse(value)< 0){
                  return "Price cannot be";
                }
                return null;
              },
              ),
              SizedBox(height: 20,),
             ElevatedButton.icon(
          onPressed: () async {
            final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
            );
            if (pickedFile != null) {
        final compressedImage = await FlutterImageCompress.compressWithFile(
          pickedFile.path,
          quality: 70,
          minWidth: 800,
          minHeight: 800,
        );
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
        final file = File(imagePath);
        await file.writeAsBytes(compressedImage!);
        setState(() {
          _imagePath = imagePath;
        });
            }
          },
          icon: Icon(Icons.camera),
          label: Text("Take Photo"),
        ),
        SizedBox(height: 25.0,),
        ElevatedButton.icon(
          onPressed: () async {
            final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
            );
            if (pickedFile != null) {
        final compressedImage = await FlutterImageCompress.compressWithFile(
          pickedFile.path,
          quality: 70,
          minWidth: 800,
          minHeight: 800,
        );
        final directory = await getTemporaryDirectory();
        final imagePath = "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
        final file = File(imagePath);
        await file.writeAsBytes(compressedImage!);
        setState(() {
          _imagePath = imagePath;
        });
            }
          },
          icon: Icon(Icons.image),
          label: Text("Select from Gallery"),
        ),
        SizedBox(height: 20,),
        if(_imagePath != null)
        Image.file(File(_imagePath!)),
        SizedBox(height: 20),
        ElevatedButton(onPressed: (){
          if(_formKey.currentState!.validate()){
            final product = Product(name: _nameController.text, 
            quantity: _nameController.text, 
            price: _priceController.text, 
            imagePath: _imagePath ?? widget.existingProduct!.imagePath,);
            final box = Hive.box<Product>('products');
            if(widget.existingProduct != null){
              // UPdate the existing product
              box.putAt(box.values.toList().indexOf(widget.existingProduct!), product);
              
              
            }else{
              box.add(product);
            }
            Navigator.pop(context);
          }
        }, child: Text(widget.existingProduct != null ? "update Product" : "save Product" ),)
          ],
        ),
      ),
      ),
    );
  }
}