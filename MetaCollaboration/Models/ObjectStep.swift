//
// ObjectStep.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation

public struct ObjectStep: Identifiable, Codable {
    public var id: String?
    public var modelId: Int?
    public var title: String?
    public var objectName: String?
    public var coordinates: [Coordinates]?
    public var steps: [Step]?
    public var instruction: Instruction?
    public var confirmation: Confirmation?
    public var order: Decimal?
    
    public init(
        id: String? = nil,
        modelId: Int? = nil,
        title: String? = nil,
        objectName: String? = nil,
        coordinates: [Coordinates]? = nil,
        steps: [Step]? = nil,
        instruction: Instruction? = nil,
        confirmation: Confirmation? = nil,
        order: Decimal? = nil
    ) {
        self.id = id
        self.modelId = modelId
        self.title = title
        self.objectName = objectName
        self.coordinates = coordinates
        self.steps = steps
        self.instruction = instruction
        self.confirmation = confirmation
        self.order = order
    }
}


#if DEBUG
// MARK: - Example ObjectStep
extension ObjectStep {
    static var example: ObjectStep {
        ObjectStep(
            id: "63ef73307b425e2daf8c9081",
            modelId: 123,
            title: "tiskova hlava",
            objectName: "toy_drummer_idle",
            steps: [
                Step(
                    id: "uid001",
                    contents: [
                        Content(contentType: .textblock, order: 1, text: "First, check that you have a screwdriver."),
                        Content(contentType: .textblock, order: 2, text: "Second, check that you have a screwdriver 2.")
                    ],
                    confirmation: Confirmation(
                        comment: "I managed to upgrade my Prusa to MK2.5S+, yahooo :)",
                        photoUrl: "photoUrl",
                        date: 1676623885569,
                        done: true
                    ),
                    order: 1
                ),
                Step(
                    id: "uid002",
                    contents: [
                        Content(contentType: .textblock, order: 1, text: "Third, check that you have a screwdriver 3."),
                        Content(contentType: .textblock, order: 2, text: "Fourth, check that you have a screwdriver 4.")
                    ],
                    confirmation: Confirmation(
                        comment: "I managed to upgrade my Prusa to MK2.5S+, yahooo :)",
                        photoUrl: "photoUrl",
                        date: 1676623885569,
                        done: false
                    ),
                    order: 2
                )
            ],
            instruction: Instruction(title: "Removing screw", text: "Remove the M3 screw from the fan holder.", imageUrl: "https://c-3d.niceshops.com/upload/image/product/large/default/bondtech-prusa-i3-mk2-mk2s-extruder-upgrade-1-ks-252884-cs.jpg"), order: 1)
    }
    
    static var exampleArray: [ObjectStep] = [
        ObjectStep(id: "63ef73307b425e2daf8c9081",
                   modelId: 123,
                   title: "tiskova hlava",
                   objectName: "toy_drummer_idle",
                   steps: [
                    Step(
                        id: "uid001",
                        contents: [
                            Content(contentType: .textblock, order: 1, text: "First, check that you have a screwdriver."),
                            Content(contentType: .textblock, order: 2, text: "Second, check that you have a screwdriver 2.")
                        ],
                        confirmation: Confirmation(
                            comment: "I managed to upgrade my Prusa to MK2.5S+, yahooo :)",
                            photoUrl: "photoUrl",
                            date: 1676623885569,
                            done: true
                        ),
                        order: 1
                    ),
                    Step(
                        id: "uid002",
                        contents: [
                            Content(contentType: .textblock, order: 1, text: "Third, check that you have a screwdriver 3."),
                            Content(contentType: .textblock, order: 2, text: "Fourth, check that you have a screwdriver 4.")
                        ],
                        confirmation: Confirmation(
                            comment: "I managed to upgrade my Prusa to MK2.5S+, yahooo :)",
                            photoUrl: "photoUrl",
                            date: 1676623885569,
                            done: false
                        ),
                        order: 2
                    )
                   ],
                   instruction: Instruction(title: "Removing screw", text: "First. Remove the M3 screw from the fan holder.", imageUrl: "https://c-3d.niceshops.com/upload/image/product/large/default/bondtech-prusa-i3-mk2-mk2s-extruder-upgrade-1-ks-252884-cs.jpg"), order: 1),
        ObjectStep(id: "63ef73307b425e2daf8c9082",
                   modelId: 234,
                   title: "tiskova hlava 2",
                   objectName: "sneaker_airforce",
                   steps: [
                    Step(
                        id: "uid001",
                        contents: [
                            Content(contentType: .textblock, order: 1, text: "First, check that you have a screwdriver."),
                            Content(contentType: .textblock, order: 2, text: "Second, check that you have a screwdriver 2.")
                        ],
                        confirmation: Confirmation(
                            comment: "I managed to upgrade my Prusa to MK2.5S+, yahooo :)",
                            photoUrl: "photoUrl",
                            date: 1676623885569,
                            done: true
                        ),
                        order: 1
                    ),
                    Step(
                        id: "uid002",
                        contents: [
                            Content(contentType: .textblock, order: 1, text: "Third, check that you have a screwdriver 3."),
                            Content(contentType: .textblock, order: 2, text: "Fourth, check that you have a screwdriver 4.")
                        ],
                        confirmation: Confirmation(
                            comment: "I managed to upgrade my Prusa to MK2.5S+, yahooo :)",
                            photoUrl: "photoUrl",
                            date: 1676623885569,
                            done: false
                        ),
                        order: 2
                    )
                   ],
                   instruction: Instruction(title: "Removing screw 2", text: "Second. Remove the M3 screw from the fan holder.", imageUrl: "https://c-3d.niceshops.com/upload/image/product/large/default/bondtech-prusa-i3-mk2-mk2s-extruder-upgrade-1-ks-252884-cs.jpg"), order: 1),
    ]
    
}
#endif
