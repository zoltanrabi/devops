body:
  - type: textarea
    id: description
    attributes:
      label: "Description"
      description: Please enter an explicit description of your implementation
      placeholder: Short and explicit description of your implementation...
    validations:
      required: true
  - type: input
    id: ticketnumber
    attributes:
      label: "Ticket number"
      description: Please enter the ticket number or other identifier if available
      placeholder: JIRATICKET-1234
    validations:
      required: false
  - type: textarea
    id: otherinfo
    attributes:
      label: "Other"
      description: If you have anything you wanna share type here
      placeholder: ...
    validations:
      required: false
  - type: dropdown
    id: type
    attributes:
      label: "Type of change"
      description: Please select the type of your change?
      multiple: true
      options:
        - Bugfix
        - New feature
        - Configuration
    validations:
      required: false