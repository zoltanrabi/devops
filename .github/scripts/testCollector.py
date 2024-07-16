import xml.etree.ElementTree as ET
import os

package_xml_path = 'package/package.xml'
classes_folder_path = './force-app/main/default/classes'
flow_folder_path = "./force-app/main/default/flows"

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
    return test_classes

def get_flows_from_package(package_xml_path):
    flows = set()
    try:
        tree = ET.parse(package_xml_path)
        root = tree.getroot()
        ns = {'pkg': 'http://soap.sforce.com/2006/04/metadata'}
        
        for types in root.findall('pkg:types', namespaces=ns):
            name = types.find('pkg:name', namespaces=ns)
            if name is not None and name.text == 'Flow':
                for member in types.findall('pkg:members', namespaces=ns):
                    flows.add(member.text)
    except ET.ParseError as e:
        print(f"Error parsing {package_xml_path}: {e}")
    
    return flows

def collect_flow_related_objects(flow_folder, flow_names):
    related_objects = set()
    
    for flow_name in flow_names:
        file_path = os.path.join(flow_folder, f"{flow_name}.flow-meta.xml")
        if os.path.exists(file_path):
            try:
                tree = ET.parse(file_path)
                root = tree.getroot()
                ns = {'md': 'http://soap.sforce.com/2006/04/metadata'}
                start_element = root.find('md:start', namespaces=ns)
                
                if start_element is not None and start_element.find('md:object', namespaces=ns) is not None:
                    trigger_type = start_element.find('md:triggerType', namespaces=ns)
                    if trigger_type is not None and trigger_type.text in ['RecordAfterSave', 'RecordBeforeDelete', 'RecordBeforeSave']:
                        object_name = start_element.find('md:object', namespaces=ns).text
                        related_objects.add(object_name)
            except ET.ParseError as e:
                print(f"Error parsing {file_path}: {e}")
    
    return related_objects

def find_test_classes(classes_folder, related_objects):
    test_classes = set()

    # Iterate through files in the specified folder
    for filename in os.listdir(classes_folder):
        if filename.endswith("Test.cls"):  # Process only classes that end with Test.cls
            class_name = filename[:-4]  # Remove the .cls suffix
            for obj in related_objects:
                if obj in class_name:
                    test_classes.add(class_name)
                    break  # Break out of inner loop if match found

    return test_classes

def extract_objects_from_package_xml(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    # Namespace to be used for finding elements
    namespace = {'sf': 'http://soap.sforce.com/2006/04/metadata'}

    # Set to store the object names
    objects_set = set()

    # Loop through types and members
    for types in root.findall('sf:types', namespace):
        name = types.find('sf:name', namespace)
        if name is not None and name.text == 'CustomObject':
            for member in types.findall('sf:members', namespace):
                if member.text:
                    objects_set.add(member.text)

    return objects_set

test_classes = list_apex_classes(package_xml_path, classes_folder_path)
flow_names = get_flows_from_package(package_xml_path)
related_objects = collect_flow_related_objects(flow_folder_path, flow_names)
related_objects.update(extract_objects_from_package_xml(package_xml_path))
test_classes.update(find_test_classes(classes_folder_path, related_objects))
print(' '.join(test_classes))