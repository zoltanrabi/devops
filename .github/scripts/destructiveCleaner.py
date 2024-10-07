import xml.etree.ElementTree as ET

def remove_unwanted_members(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    namespaces = {'': 'http://soap.sforce.com/2006/04/metadata'}

    for type_element in root.findall('types', namespaces):
        type_name = type_element.find('name', namespaces).text if type_element.find('name', namespaces) is not None else None
        for member in list(type_element.findall('members', namespaces)):
            member_text = member.text
            if '__' in member_text and not member_text.endswith('__c') or member_text.count('__') > 1:
                type_element.remove(member)
            elif type_name in ['CustomField', 'CustomObject'] and not member_text.endswith('__c'):
                type_element.remove(member)
    tree.write(xml_file, encoding='UTF-8', xml_declaration=True)

xml_file = 'destructiveChanges.xml'
remove_unwanted_members(xml_file)