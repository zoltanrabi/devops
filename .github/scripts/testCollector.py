import xml.etree.ElementTree as ET
import os

package_xml_path = 'package/package.xml'
classes_folder_path = '/home/runner/work/mydevorg/mydevorg/force-app/main/default/classes'

def list_apex_classes(package_xml_path, classes_folder_path):
    # Parse the XML file
    tree = ET.parse(package_xml_path)
    root = tree.getroot()
    
    # Namespace handling
    namespace = {'ns': 'http://soap.sforce.com/2006/04/metadata'}

    # Find all Apex classes
    test_classes = set()
    for types in root.findall('ns:types', namespace):
        name = types.find('ns:name', namespace)
        if name is not None and name.text == 'ApexClass':
            for member in types.findall('ns:members', namespace):
                apex_class_name = member.text
                
                # Check if the class name ends with 'Test'
                if apex_class_name.endswith('Test'):
                    test_classes.add(apex_class_name)
                else:
                    # Check if there is a corresponding Test class file in the classes folder
                    test_class_file = os.path.join(classes_folder_path, apex_class_name + 'Test.cls')
                    if os.path.isfile(test_class_file):
                        test_classes.add(apex_class_name + 'Test')

    string_list = ' '.join(test_classes)
    return string_list

print(list_apex_classes(package_xml_path, classes_folder_path))