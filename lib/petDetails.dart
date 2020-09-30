import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:petmedical_app/repository/DataRepository.dart';
import 'package:petmedical_app/utils/constants.dart';

import 'models/vaccination.dart';
import 'models/pets.dart';

typedef DialogCallback = void Function();

class PetDetails extends StatelessWidget {
  final Pet pet;

  const PetDetails(this.pet);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(pet.name == null ? "" : pet.name),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: PetDetailForm(pet),
      ),
    );
  }
}

class PetDetailForm extends StatefulWidget {
  final Pet pet;
  const PetDetailForm(this.pet);

  @override
  _PetDetailFormState createState() => _PetDetailFormState();
}

class _PetDetailFormState extends State<PetDetailForm> {
  final DataRepository repository = DataRepository();
  final _formKey = GlobalKey<FormBuilderState>();
  final dateFormat = DateFormat('yyyy-MM-dd');
  String name;
  String type;
  String notes;

  @override
  void initState() {
    type = widget.pet.type;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: FormBuilder(
        key: _formKey,
        autovalidate: true,
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            FormBuilderTextField(
              attribute: "name",
              initialValue: widget.pet.name,
              decoration: textInputDecoration.copyWith(
                  hintText: 'Name', labelText: "Pet Name"),
              validators: [
                FormBuilderValidators.minLength(1),
                FormBuilderValidators.required()
              ],
              onChanged: (val) {
                setState(() => name = val);
              },
            ),
            FormBuilderRadio(
              decoration: InputDecoration(labelText: 'Animal Type'),
              attribute: "cat",
              initialValue: type,
              leadingInput: true,
              options: [
                FormBuilderFieldOption(
                    value: "cat",
                    child: Text(
                      "Cat",
                      style: TextStyle(fontSize: 16.0),
                    )),
                FormBuilderFieldOption(
                    value: "dog",
                    child: Text(
                      "Dog",
                      style: TextStyle(fontSize: 16.0),
                    )),
                FormBuilderFieldOption(
                    value: "other",
                    child: Text(
                      "Other",
                      style: TextStyle(fontSize: 16.0),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  type = value;
                });
              },
            ),
            SizedBox(height: 20.0),
            FormBuilderTextField(
              attribute: "notes",
              initialValue: widget.pet.notes,
              decoration: textInputDecoration.copyWith(
                  hintText: 'Notes', labelText: "Notes"),
              onChanged: (val) {
                setState(() {
                  notes = val;
                });
              },
            ),
            FormBuilderCustomField(
              attribute: "vaccinations",
              formField: FormField(
                enabled: true,
                builder: (FormFieldState<dynamic> field) {
                  return Column(
                    children: <Widget>[
                      SizedBox(height: 6.0),
                      Text(
                        "Vaccinations",
                        style: TextStyle(fontSize: 16.0),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(16.0),
                          itemCount: widget.pet.vaccinations == null
                              ? 0
                              : widget.pet.vaccinations.length,
                          itemBuilder: (BuildContext context, int index) {
                            return buildRow(widget.pet.vaccinations[index]);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                _addVaccination(widget.pet, () {
                  setState(() {});
                });
              },
              tooltip: 'Add Vaccination',
              child: Icon(Icons.add),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                    color: Colors.blue.shade600,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    )),
                MaterialButton(
                    color: Colors.blue.shade600,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        Navigator.of(context).pop();
                        widget.pet.name = name;
                        widget.pet.type = type;
                        widget.pet.notes = notes;

                        repository.updatePet(widget.pet);
                      }
                    },
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(Vaccination vaccination) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(vaccination.vaccination),
        ),
        Text(vaccination.date == null
            ? ""
            : dateFormat.format(vaccination.date)),
        Checkbox(
          value: vaccination.done == null ? false : vaccination.done,
          onChanged: (newValue) {
            vaccination.done = newValue;
          },
        )
      ],
    );
  }

  void _addVaccination(Pet pet, DialogCallback callback) {
    String vaccination;
    DateTime vaccinationDate;
    bool done = false;
    final _formKey = GlobalKey<FormBuilderState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Vaccination"),
              content: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  autovalidate: true,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        attribute: "vaccination",
                        validators: [
                          FormBuilderValidators.minLength(1),
                          FormBuilderValidators.required()
                        ],
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Enter a Vaccination Name',
                            labelText: "Vaccination"),
                        onChanged: (text) {
                          setState(() {
                            vaccination = text;
                          });
                        },
                      ),
                      FormBuilderDateTimePicker(
                        attribute: "date",
                        inputType: InputType.date,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Enter a Vaccination Date',
                            labelText: "Date"),
                        onChanged: (text) {
                          setState(() {
                            vaccinationDate = text;
                          });
                        },
                      ),
                      FormBuilderCheckbox(
                        attribute: "given",
                        label: Text("Given"),
                        onChanged: (text) {
                          setState(() {
                            done = text;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel")),
                FlatButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Navigator.of(context).pop();

                        Vaccination newVaccination = Vaccination(vaccination,
                            date: vaccinationDate, done: done);
                        if (pet.vaccinations == null) {
                          pet.vaccinations = List<Vaccination>();
                        }
                        pet.vaccinations.add(newVaccination);
                      }
                      callback();
                    },
                    child: Text("Add")),
              ]);
        });
  }
}
